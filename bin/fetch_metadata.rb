#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off: pull ALL posts (with original Markdown + metadata) and series from
# the Hashnode GraphQL API, and freeze them to bin/data/. Run this while you
# still have API access.
#
# Auth: reads a Hashnode Personal Access Token from either
#   - the HASHNODE_TOKEN environment variable, or
#   - the file bin/.hashnode_token  (gitignored)
# Get a token at Hashnode -> Account Settings -> Developer -> Personal Access Tokens.
#
# Usage:  ruby bin/fetch_metadata.rb
# Output: bin/data/hashnode_posts.json    (slug, title, dates, tags, cover, seo, series, content.markdown)
#         bin/data/hashnode_series.json   (slug, name, description, ordered member slugs)
#         bin/data/live_sitemap.xml
#         bin/data/live_rss.xml
#
# Stdlib only -- no bundler needed.

require "net/http"
require "json"
require "uri"
require "fileutils"

HOST     = "allaboutcoding.ghinda.com"
GQL_URL  = URI("https://gql-beta.hashnode.com/")
DATA_DIR = File.expand_path("data", __dir__)
FileUtils.mkdir_p(DATA_DIR)

def load_token
  return ENV["HASHNODE_TOKEN"] if ENV["HASHNODE_TOKEN"] && !ENV["HASHNODE_TOKEN"].empty?
  path = File.expand_path(".hashnode_token", __dir__)
  return File.read(path).strip if File.exist?(path)
  abort "No Hashnode token. Set HASHNODE_TOKEN or create bin/.hashnode_token (gitignored)."
end

TOKEN = load_token

def gql(query, variables = {})
  req = Net::HTTP::Post.new(GQL_URL)
  req["Content-Type"]  = "application/json"
  req["Authorization"] = TOKEN
  req["User-Agent"]    = "allaboutcoding-migration/1.0"
  req.body = JSON.generate(query: query, variables: variables)

  res = Net::HTTP.start(GQL_URL.host, GQL_URL.port, use_ssl: true) { |http| http.request(req) }

  if res.is_a?(Net::HTTPRedirection)
    abort "HTTP #{res.code} redirect to #{res["location"]} -- endpoint may have moved or auth was rejected."
  end
  unless res.is_a?(Net::HTTPSuccess)
    abort "HTTP #{res.code} from Hashnode:\n#{res.body[0, 500]}"
  end

  parsed = JSON.parse(res.body)
  abort "GraphQL errors:\n#{JSON.pretty_generate(parsed["errors"])}" if parsed["errors"]
  parsed.fetch("data")
end

POSTS_QUERY = <<~GQL
  query Posts($host: String!, $after: String) {
    publication(host: $host) {
      id
      title
      posts(first: 20, after: $after) {
        edges {
          node {
            id
            slug
            title
            subtitle
            brief
            publishedAt
            updatedAt
            readTimeInMinutes
            canonicalUrl
            content { markdown }
            coverImage { url }
            ogMetaData { image }
            seo { title description }
            series { id name slug }
            tags { id name slug }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
GQL

DRAFTS_QUERY = <<~GQL
  query Drafts($host: String!, $after: String) {
    publication(host: $host) {
      drafts(first: 20, after: $after) {
        edges {
          node {
            id
            title
            subtitle
            slug
            updatedAt
            readTimeInMinutes
            canonicalUrl
            content { markdown }
            coverImage { url }
            seo { title description }
            tags { id name slug }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
GQL

SERIES_QUERY = <<~GQL
  query SeriesList($host: String!, $after: String) {
    publication(host: $host) {
      seriesList(first: 20, after: $after) {
        edges {
          node {
            id
            name
            slug
            description { markdown }
            posts(first: 50) {
              edges { node { slug title publishedAt } }
              pageInfo { hasNextPage endCursor }
            }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
GQL

# ---- All posts (paginated) -------------------------------------------------
posts = []
after = nil
page  = 0
loop do
  page += 1
  conn  = gql(POSTS_QUERY, { host: HOST, after: after })
          .fetch("publication").fetch("posts")
  batch = conn["edges"].map { |e| e["node"] }
  posts.concat(batch)
  warn "posts page #{page}: +#{batch.size} (total #{posts.size})"
  break unless conn.dig("pageInfo", "hasNextPage")
  after = conn.dig("pageInfo", "endCursor")
end

# ---- All drafts (paginated) ------------------------------------------------
drafts = []
after  = nil
loop do
  conn = gql(DRAFTS_QUERY, { host: HOST, after: after }).dig("publication", "drafts")
  break unless conn
  drafts.concat(conn["edges"].map { |e| e["node"] })
  break unless conn.dig("pageInfo", "hasNextPage")
  after = conn.dig("pageInfo", "endCursor")
end
warn "drafts: #{drafts.size}"

# ---- All series (paginated) ------------------------------------------------
series = []
after  = nil
loop do
  conn = gql(SERIES_QUERY, { host: HOST, after: after }).dig("publication", "seriesList")
  break unless conn
  series.concat(conn["edges"].map { |e| e["node"] })
  break unless conn.dig("pageInfo", "hasNextPage")
  after = conn.dig("pageInfo", "endCursor")
end
warn "series: #{series.size}"

# ---- Live sitemap + RSS (public, for cross-checking) -----------------------
sitemap = Net::HTTP.get(URI("https://#{HOST}/sitemap.xml"))
rss     = Net::HTTP.get(URI("https://#{HOST}/rss.xml"))

File.write(File.join(DATA_DIR, "hashnode_posts.json"),  JSON.pretty_generate(posts))
File.write(File.join(DATA_DIR, "hashnode_drafts.json"), JSON.pretty_generate(drafts))
File.write(File.join(DATA_DIR, "hashnode_series.json"), JSON.pretty_generate(series))
File.write(File.join(DATA_DIR, "live_sitemap.xml"),     sitemap)
File.write(File.join(DATA_DIR, "live_rss.xml"),         rss)

warn "\nWrote:"
warn "  #{posts.size} posts  -> data/hashnode_posts.json"
warn "  #{drafts.size} drafts -> data/hashnode_drafts.json"
warn "  #{series.size} series -> data/hashnode_series.json"
warn "  sitemap (#{sitemap.bytesize} B) -> data/live_sitemap.xml"
warn "  rss (#{rss.bytesize} B) -> data/live_rss.xml"
