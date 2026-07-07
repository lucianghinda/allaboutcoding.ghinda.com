#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off: turn the frozen Hashnode API dump (bin/data/hashnode_posts.json and
# hashnode_series.json, produced by bin/fetch_metadata.rb) into a Jekyll site:
#
#   _posts/YYYY-MM-DD-<slug>.md      one per published post
#   _data/series.yml                 series -> ordered member slugs
#   series/<slug>.md                 one stub page per series
#   assets/images/posts/<slug>/...   downloaded Hashnode CDN images
#
# Idempotent: wipes and regenerates _posts, _data/series.yml and series/*.md on
# every run; image downloads are skip-if-exists.
#
# Usage:  ruby bin/migrate.rb
#
# Stdlib only.

require "json"
require "yaml"
require "fileutils"
require "time"
require "uri"
require "net/http"

ROOT       = File.expand_path("..", __dir__)          # apps/blog
DATA       = File.expand_path("data", __dir__)        # apps/blog/bin/data
POSTS_DIR  = File.join(ROOT, "_posts")
DRAFTS_DIR = File.join(ROOT, "_drafts")
SERIES_DIR = File.join(ROOT, "series")
DATA_OUT   = File.join(ROOT, "_data")
IMG_ROOT   = File.join(ROOT, "assets", "images", "posts")
IMG_URL    = "/assets/images/posts"

def sluggify(text)
  text.to_s.downcase.gsub(/[`'"]/, "").gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
end

# ---------------------------------------------------------------------------
# Body transforms (pure-ish; image localization has the download side effect)
# ---------------------------------------------------------------------------

# Remove Hashnode's non-standard `align="..."` attribute inside image markdown:
#   ![alt](https://.../x.png align="center")  ->  ![alt](https://.../x.png)
def strip_align(md)
  md.gsub(/(!\[[^\]]*\]\([^)\s]+)\s+align="[^"]*"\)/, '\1)')
end

def youtube_id(url)
  u = URI.parse(url)
  return URI.decode_www_form(u.query.to_s).to_h["v"] if u.host&.include?("youtube.com")
  return u.path.sub(%r{\A/}, "") if u.host&.include?("youtu.be")
  nil
rescue URI::InvalidURIError
  nil
end

def twitter_status?(url)
  u = URI.parse(url)
  !!(u.host&.match?(/(?:\A|\.)(twitter\.com|x\.com)\z/) && u.path.include?("/status/"))
rescue URI::InvalidURIError
  false
end

# Convert Hashnode embed directives to Jekyll includes.
#   %[https://youtu.be/ID]                -> {% include embed/youtube.html id="ID" %}
#   %[https://twitter.com/u/status/123]   -> {% include embed/tweet.html url="..." %}
#   %%[shortruby]                         -> {% include newsletter.html %}
#   %[anything-else]                      -> plain markdown link + recorded for review
def convert_embeds(md, unknown_sink)
  md = md.gsub(/^\s*%%\[(\w+)\]\s*$/) do
    name = Regexp.last_match(1)
    if name == "shortruby"
      "{% include newsletter.html %}"
    else
      unknown_sink << "%%[#{name}]"
      "{% include newsletter.html %}"
    end
  end

  md.gsub(/^\s*%\[(\S+?)\]\s*$/) do
    url = Regexp.last_match(1)
    if (id = youtube_id(url))
      %({% include embed/youtube.html id="#{id}" %})
    elsif twitter_status?(url)
      %({% include embed/tweet.html url="#{url}" %})
    else
      unknown_sink << url
      "[#{url}](#{url})"
    end
  end
end

# Find every cdn.hashnode.com URL in the text, download it under the post's
# image dir, and rewrite the reference to the local path. Returns [new_text, failures].
def localize_images(text, slug, failures)
  dir = File.join(IMG_ROOT, slug)
  text.gsub(%r{https?://cdn\.hashnode\.com/[^\s)"'>]+}) do |url|
    basename = File.basename(URI.parse(url).path)
    basename = "image" if basename.empty?
    dest = File.join(dir, basename)
    unless File.exist?(dest)
      begin
        FileUtils.mkdir_p(dir)
        download(url, dest)
      rescue => e
        failures << "#{slug}: #{url} (#{e.class}: #{e.message})"
        next url # leave the remote URL in place if the download failed
      end
    end
    "#{IMG_URL}/#{slug}/#{basename}"
  end
end

def download(url, dest, redirects = 3)
  raise "too many redirects" if redirects.negative?
  uri = URI.parse(url)
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 15, read_timeout: 30) do |http|
    http.get(uri.request_uri, "User-Agent" => "allaboutcoding-migration/1.0")
  end
  case res
  when Net::HTTPSuccess     then File.binwrite(dest, res.body)
  when Net::HTTPRedirection then download(res["location"], dest, redirects - 1)
  else raise "HTTP #{res.code}"
  end
end

# ---------------------------------------------------------------------------
# Emit one post
# ---------------------------------------------------------------------------

def build_post(node, unknown_sink, img_failures)
  slug = node["slug"]
  body = node.dig("content", "markdown")
  return nil if slug.to_s.empty? || body.to_s.empty?

  body = strip_align(body)
  body = convert_embeds(body, unknown_sink)
  body = localize_images(body, slug, img_failures)

  date = Time.parse(node["publishedAt"])

  fm = { "layout" => "post", "title" => node["title"], "date" => date.strftime("%Y-%m-%d %H:%M:%S %z") }
  fm["slug"] = slug
  if (sub = node["subtitle"]) && !sub.empty?
    fm["subtitle"] = sub
  end
  tags = (node["tags"] || []).map { |t| t["slug"] }.compact
  fm["tags"] = tags unless tags.empty?
  if (desc = node.dig("seo", "description") || node["brief"]) && !desc.to_s.empty?
    fm["description"] = desc.to_s.strip
  end
  if (cover = node.dig("coverImage", "url"))
    fm["image"] = localize_images(cover, slug, img_failures)
  end
  if (canon = node["canonicalUrl"]) && !canon.to_s.empty?
    fm["canonical_url"] = canon
  end
  if (last = node["updatedAt"]) && !last.to_s.empty?
    fm["last_modified_at"] = Time.parse(last).strftime("%Y-%m-%d %H:%M:%S %z")
  end

  filename = "#{date.strftime('%Y-%m-%d')}-#{slug}.md"
  content  = YAML.dump(fm) + "---\n\n" + body.strip + "\n"
  [filename, content]
end

# Build a Jekyll draft (unpublished) from a Hashnode draft node.
def build_draft(node, img_failures)
  title = node["title"].to_s.strip
  body  = node.dig("content", "markdown").to_s
  slug  = node["slug"].to_s.strip
  slug  = sluggify(title) if slug.empty?
  slug  = "untitled-#{node['id']}" if slug.empty?
  return nil if title.empty? && body.strip.empty?

  # Drafts are unpublished: keep their images on Hashnode's CDN rather than
  # downloading unpublished assets into the site. Localize when a draft ships.
  body = strip_align(body)
  body = convert_embeds(body, [])

  fm = { "layout" => "post", "title" => (title.empty? ? slug.tr("-", " ") : title) }
  if (sub = node["subtitle"]) && !sub.to_s.empty?
    fm["subtitle"] = sub
  end
  fm["date"] = Time.parse(node["updatedAt"]).strftime("%Y-%m-%d %H:%M:%S %z") if node["updatedAt"]
  if (canon = node["canonicalUrl"]) && !canon.to_s.empty?
    fm["canonical_url"] = canon
  end
  fm["published"] = false          # never publish, even if moved out of _drafts by accident
  fm["hashnode_draft_id"] = node["id"]

  content = YAML.dump(fm) + "---\n\n" + body.strip + "\n"
  ["#{slug}.md", content]
end

# ---------------------------------------------------------------------------
# Series
# ---------------------------------------------------------------------------

def build_series(series_nodes)
  entries = series_nodes.map do |s|
    slugs = s.dig("posts", "edges").to_a.map { |e| e.dig("node", "slug") }.compact
    {
      "slug"        => s["slug"],
      "name"        => s["name"],
      "description" => (s.dig("description", "markdown") || "").strip,
      "posts"       => slugs,
    }
  end
  # Keep empty series too: their URLs exist in the sitemap and must be preserved.
  entries
end

def series_stub(entry)
  fm = {
    "layout"      => "series",
    "title"       => entry["name"],
    "permalink"   => "/series/#{entry['slug']}/",
    "series_slug" => entry["slug"],
  }
  YAML.dump(fm) + "---\n"
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main
  posts  = JSON.parse(File.read(File.join(DATA, "hashnode_posts.json")))
  series = JSON.parse(File.read(File.join(DATA, "hashnode_series.json")))
  drafts_path = File.join(DATA, "hashnode_drafts.json")
  drafts = File.exist?(drafts_path) ? JSON.parse(File.read(drafts_path)) : []

  # Reset generated outputs (idempotent)
  FileUtils.rm_rf(POSTS_DIR);  FileUtils.mkdir_p(POSTS_DIR)
  FileUtils.rm_rf(DRAFTS_DIR); FileUtils.mkdir_p(DRAFTS_DIR)
  FileUtils.rm_rf(SERIES_DIR); FileUtils.mkdir_p(SERIES_DIR)
  FileUtils.mkdir_p(DATA_OUT)

  unknown_embeds = []
  img_failures   = []
  written        = 0
  skipped        = []

  posts.each do |node|
    result = build_post(node, unknown_embeds, img_failures)
    if result.nil?
      skipped << (node["slug"] || node["id"])
      next
    end
    filename, content = result
    File.write(File.join(POSTS_DIR, filename), content)
    written += 1
  end

  # Drafts -> _drafts/ (unpublished; built only with `jekyll build --drafts`)
  drafts_written = 0
  drafts_skipped = 0
  seen_draft = {}
  drafts.each do |node|
    result = build_draft(node, img_failures)
    if result.nil?
      drafts_skipped += 1
      next
    end
    filename, content = result
    if seen_draft[filename] # de-dupe slug collisions
      base = File.basename(filename, ".md")
      filename = "#{base}-#{seen_draft[filename] += 1}.md"
    else
      seen_draft[filename] = 1
    end
    File.write(File.join(DRAFTS_DIR, filename), content)
    drafts_written += 1
  end

  series_entries = build_series(series)
  File.write(File.join(DATA_OUT, "series.yml"), YAML.dump(series_entries))
  series_entries.each do |entry|
    File.write(File.join(SERIES_DIR, "#{entry['slug']}.md"), series_stub(entry))
  end

  # ---- Reconciliation report ------------------------------------------------
  sitemap = File.join(DATA, "live_sitemap.xml")
  live_slugs =
    if File.exist?(sitemap)
      File.read(sitemap).scan(%r{<loc>https?://[^/]+/([^/<]+)</loc>}).flatten
          .reject { |s| s.start_with?("series") } - %w[archive recommendations]
    else
      []
    end
  api_slugs = posts.map { |n| n["slug"] }.compact

  warn "\n=== migration report ==="
  warn "posts written:        #{written}"
  warn "posts skipped (empty): #{skipped.size} #{skipped.inspect unless skipped.empty?}"
  warn "drafts written:       #{drafts_written} (skipped #{drafts_skipped})"
  warn "series written:       #{series_entries.size}"
  unless live_slugs.empty?
    warn "sitemap articles:     #{live_slugs.size}"
    warn "  in sitemap, NOT migrated: #{(live_slugs - api_slugs).sort.inspect}"
    warn "  migrated, NOT in sitemap: #{(api_slugs - live_slugs).sort.inspect}"
  end
  warn "unknown embeds (review): #{unknown_embeds.uniq.inspect}" unless unknown_embeds.empty?
  warn "image download failures: #{img_failures.size}"
  img_failures.first(20).each { |f| warn "  #{f}" }
  warn "========================\n"
end

main if $PROGRAM_NAME == __FILE__
