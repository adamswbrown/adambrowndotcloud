# Claude Code Configuration - adambrown.cloud

Personal blog and portfolio site built with Hugo and the Toha theme.

## Project Overview

- **Type**: Static site (Hugo)
- **Theme**: Toha v4 (via Hugo modules)
- **Live URL**: https://adambrown.cloud
- **Deployment**: Netlify + GitHub Pages (dual deployment)

## Quick Commands

```bash
# Development server (hot reload)
hugo server -w

# Production build
hugo --gc --minify

# Update Hugo modules
hugo mod tidy

# Install npm dependencies (after module changes)
hugo mod npm pack && npm install
```

## Directory Structure

```
content/
├── posts/          # Blog posts (each in own folder with index.md)
├── notes/          # Technical notes (go/, bash/)
├── now.md          # "Now" page
└── admin.md        # CMS config
layouts/            # Hugo templates and partials
assets/
├── styles/         # CSS files
├── js/             # JavaScript
└── images/         # Asset images (hero images go here)
static/             # Static files (copied directly to output)
data/               # Hugo data files
public/             # Build output (generated, gitignored)
```

## Creating Content

### New Blog Post

Create `content/posts/[slug]/index.md`:

```yaml
---
title: "Post Title"
date: 2026-01-31T08:00:00Z
draft: false
hero: images/posts/[slug]/hero.svg
description: "Short description for SEO and cards"
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: ["tag1", "tag2"]
categories: ["Category"]
---

Content goes here...
```

**IMPORTANT — post date must be in the past at build time.** Hugo's `buildFuture` is unset (defaults to `false`), so any post dated even a minute in the future is silently dropped from the build. When publishing today, set the date to early-morning UTC (e.g. `T08:00:00Z`) — never the current time, and never round numbers like `T10:00:00Z` that risk being ahead of the build server. Both previous publishing incidents on this blog (commits `0ad2eb8` and `4267430`) were caused by this. If a post you just merged isn't appearing on the live site, this is the first thing to check.

### Hero Images

Place hero images in `assets/images/posts/[slug]/` (not `static/`).

### Technical Notes

Create under `content/notes/[topic]/[subtopic]/index.md` with similar front matter.

## Configuration

- **hugo.yaml**: Main Hugo configuration (theme settings, features)
- **netlify.toml**: Deployment settings and redirects
- **package.json**: npm dependencies for theme features

## Key Features (Enabled)

- Light/Dark theme toggle
- KaTeX math rendering (use `$$` or `\[` delimiters)
- Mermaid flowcharts
- Code syntax highlighting with copy button
- Reading time estimates
- Tags on post cards

## Deployment

Push to `main` triggers:
1. GitHub Actions builds the site
2. Deploys to GitHub Pages (`gh-pages` branch)
3. Netlify also builds and deploys

## Netlify Redirects

Add redirects to `netlify.toml` at the end of the file.

### External Redirect (301)

```toml
[[redirects]]
  from = "/short-path"
  to = "https://external-url.com/full-path"
  status = 301
  force = true
```

### Internal Redirect

```toml
[[redirects]]
  from = "/old-path"
  to = "/new-path"
  status = 301
  force = true
```

### Rewrite (Proxy - keeps URL in browser)

```toml
[[redirects]]
  from = "/app/*"
  to = "/app/index.html"
  status = 200
```

### Common Use Cases

| Purpose | From | To | Status |
|---------|------|-----|--------|
| Booking link | `/book` | Calendly URL | 301 |
| Resource shortlink | `/resource-name` | External URL | 301 |
| SPA routing | `/admin/*` | `/admin/index.html` | 200 |
| Path rename | `/old-post` | `/new-post` | 301 |

**Notes:**
- `force = true` overrides any existing content at that path
- Status 301 = permanent redirect (cached by browsers)
- Status 302 = temporary redirect
- Status 200 = rewrite/proxy (URL stays the same in browser)

## Conventions

- Use kebab-case for post slugs: `my-new-post/`
- Keep posts in their own directories with `index.md`
- Draft posts: set `draft: true` in front matter
- Images referenced in posts should use relative paths from the post directory
