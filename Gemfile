source "https://rubygems.org"

gem "jekyll", "~> 4.4.1"

# Latent semantic indexing, used by bin/compute_related_posts.rb to rank
# related posts. Local only: the deploy build reads the committed result in
# _data/related_posts.yml and never runs the indexer.
gem "classifier-reborn", group: :development

# classifier-reborn picks its SVD backend at require time: numo, then GSL,
# then a pure-Ruby matrix. The Ruby one takes ~16 minutes to index this site.
#
# Optional group, so a plain `bundle install` (CI included) skips it and falls
# back to pure Ruby. To enable it locally you need OpenBLAS, and numo-linalg
# has to be built against it -- its library paths are baked in at build time:
#
#   brew install openblas
#   bundle config set --local with lsi
#   gem install numo-linalg -- --with-openblas-dir=$(brew --prefix openblas) \
#                              --with-backend=openblas
#   bundle install
group :lsi, optional: true do
  gem "numo-narray"
  gem "numo-linalg"
end
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
  gem "jekyll-toc"                  # toshimaru/jekyll-toc: per-post TOC, enabled with `toc: true` front matter
  gem "jekyll-redirect-from"        # jekyll/jekyll-redirect-from: `redirect_from:` front matter for old/wrong URLs
  gem "jekyll-agent-markdown"       # lucianghinda/jekyll-agent-markdown: raw .md for posts/pages, plus /llms.txt
end

# Selects Tailwind v4 for jekyll-tailwind (bundles the standalone CLI binary)
gem "tailwindcss-ruby", "~> 4.0"

# Windows / JRuby zoneinfo
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", platforms: [:mingw, :x64_mingw, :mswin]
