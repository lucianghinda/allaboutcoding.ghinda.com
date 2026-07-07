# allaboutcoding.ghinda.com — Jekyll site

Ruby & Rails blog by Lucian Ghinda, migrated from Hashnode to Jekyll.
Theme based on [jekyll-blahg](https://github.com/vormwald/jekyll-blahg) (MIT),
with [crbelaus/jekyll-tailwind](https://github.com/crbelaus/jekyll-tailwind) for Tailwind v4 (no Node).

Articles are served at root-level slugs (`/:title/`) to preserve the existing
Hashnode URLs.

## Local development

Requires Ruby 3.4.7 (see `.ruby-version`).

```sh
bundle install
bundle exec jekyll serve          # http://localhost:4000
# or: bin/dev
```

Tailwind is compiled by the jekyll-tailwind plugin during the Jekyll build,
from `_tailwind.css` into `_site/assets/css/styles.css`. No `node_modules`.

## Migration runbook (one-off)

The `_posts/`, `_data/series.yml`, `series/*.md`, and `assets/images/posts/`
are all **generated** from a frozen dump of the Hashnode API. To (re)generate:

1. **Provide a Hashnode API token.** Put it as the only contents of
   `bin/.hashnode_token` (gitignored). Get one at Hashnode → Account Settings →
   Developer → Personal Access Tokens. Alternatively `export HASHNODE_TOKEN=...`.

2. **Fetch + freeze the source data** (do this while you still have API access):

   ```sh
   ruby bin/fetch_metadata.rb
   ```

   Writes `bin/data/hashnode_posts.json`, `hashnode_series.json`,
   `live_sitemap.xml`, `live_rss.xml`. Commit these — the API is Pro-gated and
   goes away once the publication is unpublished.

3. **Generate the site content:**

   ```sh
   ruby bin/migrate.rb
   ```

   Idempotent. Prints a reconciliation report (posts written, sitemap parity,
   unknown embeds, image-download failures).

4. **Build and verify URL parity:**

   ```sh
   bundle exec jekyll build
   ruby bin/verify_urls.rb        # exits non-zero if any live URL is missing
   ```

### What the migration does per post

- Frontmatter from the API: `title`, `date`, `slug`, `tags`, `description`
  (SEO), `image` (cover), `canonical_url`, `subtitle`, `last_modified_at`.
- Body: strips Hashnode's `align="..."` image attribute; converts `%[youtube]`
  and `%[twitter]` embeds to `_includes/embed/*`; converts `%%[shortruby]` to
  `_includes/newsletter.html`; downloads every `cdn.hashnode.com` image into
  `assets/images/posts/<slug>/` and rewrites the reference.

## Deploy (GitHub Pages)

`.github/workflows/deploy.yml` builds with Jekyll, runs `bin/verify_urls.rb` as
a gate, and deploys to GitHub Pages. Repo Settings → Pages → Source: **GitHub
Actions**. Set the custom domain `allaboutcoding.ghinda.com` there.

**Cutover (keep Hashnode live until verified):** verify the domain in GitHub
Pages settings first (closes the takeover window) → lower DNS TTL → point the
`allaboutcoding` CNAME at `<user>.github.io` → wait for the TLS cert → enforce
HTTPS → re-check every sitemap URL live → only then unpublish Hashnode.
Keep `../backup-articles` and `bin/data/` forever.
