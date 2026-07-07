#!/usr/bin/env ruby
# frozen_string_literal: true

# Verify that every URL in the frozen live Hashnode sitemap has a corresponding
# file in the freshly built _site/. This is the URL-preservation gate: it runs
# locally and in CI, and exits non-zero if any article or series URL is missing.
#
# Usage:  ruby bin/verify_urls.rb [path/to/_site]
#
# Stdlib only.

require "uri"

SITE_DIR   = ARGV[0] || File.expand_path("../_site", __dir__)
SITEMAP    = File.expand_path("data/live_sitemap.xml", __dir__)
# Live URLs known to be reachable but intentionally absent from the sitemap.
# (Rebuilt on the new site from backup content; checked separately.)
EXTRA_LIVE = %w[
  searching-for-live-principles
  how-to-open-rails-console-in-safe-mode-on-gcp-k8s
]
# Live sitemap paths we deliberately do NOT recreate (won't fail the build).
IGNORE_PATHS = %w[/recommendations]

abort "Missing #{SITEMAP} -- run bin/fetch_metadata.rb first." unless File.exist?(SITEMAP)
abort "Missing #{SITE_DIR} -- run `bundle exec jekyll build` first." unless Dir.exist?(SITE_DIR)

def present?(path)
  clean = path.sub(%r{\A/}, "").sub(%r{/\z}, "")
  return File.exist?(File.join(SITE_DIR, "index.html")) if clean.empty?
  [
    File.join(SITE_DIR, clean, "index.html"),
    File.join(SITE_DIR, "#{clean}.html"),
    File.join(SITE_DIR, clean),
  ].any? { |f| File.file?(f) }
end

def categorize(path)
  return :root    if path == "/" || path.empty?
  return :series  if path.start_with?("/series/")
  return :page    if IGNORE_PATHS.include?(path) || %w[/archive].include?(path)
  :article
end

xml  = File.read(SITEMAP)
locs = xml.scan(%r{<loc>(.*?)</loc>}m).flatten.map(&:strip)

buckets = Hash.new { |h, k| h[k] = { ok: [], missing: [] } }
locs.each do |loc|
  path = URI(loc).path
  cat  = categorize(path)
  (present?(path) ? buckets[cat][:ok] : buckets[cat][:missing]) << path
end

# Extra live posts not in the sitemap
EXTRA_LIVE.each do |slug|
  (present?("/#{slug}") ? buckets[:extra][:ok] : buckets[:extra][:missing]) << "/#{slug}"
end

puts "URL parity check against #{File.basename(SITEMAP)} -> #{SITE_DIR}"
puts "-" * 60
%i[root article series page extra].each do |cat|
  b = buckets[cat]
  next if b[:ok].empty? && b[:missing].empty?
  printf("  %-8s  ok: %3d   missing: %3d\n", cat, b[:ok].size, b[:missing].size)
  b[:missing].each { |p| puts "      MISSING: #{p}" }
end
puts "-" * 60

# Fail only on article/series/extra misses; /recommendations is allowed to be absent.
hard_missing = buckets[:article][:missing] + buckets[:series][:missing] + buckets[:extra][:missing]
page_missing = buckets[:page][:missing].reject { |p| IGNORE_PATHS.include?(p) }
hard_missing += page_missing

if hard_missing.empty?
  puts "OK: all required URLs are present."
  exit 0
else
  puts "FAIL: #{hard_missing.size} required URL(s) missing."
  exit 1
end
