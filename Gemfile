source "https://rubygems.org"

gem "jekyll", "~> 4.4.1"
gem "csv"

# Ruby 3.4+ no longer bundles these; needed by Jekyll / jekyll serve
gem "webrick", group: :development
gem "base64"
gem "bigdecimal"

group :jekyll_plugins do
  gem "jekyll-sitemap"
  gem "jekyll-seo-tag"
  gem "jekyll-tailwind", "~> 2.0"   # crbelaus/jekyll-tailwind: drives the standalone tailwind CLI, no Node
  gem "jemoji"
  gem "jekyll-paginate-v2"
  gem "jekyll-tagging"
end

# Selects Tailwind v4 for jekyll-tailwind (bundles the standalone CLI binary)
gem "tailwindcss-ruby", "~> 4.0"

# Windows / JRuby zoneinfo
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", platforms: [:mingw, :x64_mingw, :mswin]
