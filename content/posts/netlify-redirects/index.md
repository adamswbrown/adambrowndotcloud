---
title: "Why I Use Netlify Redirects (and Not Hugo's)"
date: 2025-05-11T10:00:00Z
draft: false
hero: images/posts/netlify-redirects/hero.svg
description: "How I simplified my personal site by switching from Hugo's built-in aliases to Netlify redirects—and why it just works better."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A clean web route sign symbolizing flexible site navigation and modern workflows"
tags: ["netlify", "redirects", "hugo", "calendly", "productivity"]
categories: ["Productivity", "Tech"]
---

One of the most useful things I’ve done for my personal site recently is set up short, memorable URLs that redirect to the tools and platforms I use every day. For example, if you want to book a meeting with me, you can now just visit:

```
/book
```

…which will redirect you to my [Calendly page](https://calendly.com/d/crsy-9v5-m4y).

### The Problem with Hugo Redirects

At first, I tried to use Hugo’s built-in redirect system. Hugo supports redirects through a combination of page front matter and generated `aliases`, but I ran into a couple of issues:

- **They don’t support external URLs** — Hugo’s redirect aliases are primarily for internal page changes (like old URLs pointing to new ones). You can’t just say “take `/book` and go to Calendly.”
- **They generate HTML files** — Each redirect creates an HTML file with a meta refresh tag and JavaScript, which feels clunky and slow for something as simple as a redirect.
- **Hard to manage** — There’s no centralized way to manage a bunch of redirects across the site. It felt scattered and fragile.

### Enter: Netlify Redirects via `netlify.toml`

Since I deploy my site using Netlify, I discovered a much cleaner and more powerful alternative: defining redirect rules directly in my `netlify.toml` file. It looks something like this:

```toml
[[redirects]]
  from = “/book”
  to = “https://calendly.com/d/crsy-9v5-m4y”
  status = 301
  force = true
```

You just drop this at the end of your `netlify.toml`, commit, push—and it works.

### Why This Is Better

- **Fast and clean** — These redirects are handled by Netlify’s CDN edge nodes, so they’re instant and invisible.
- **Supports external URLs** — Point anywhere you like, not just to content within your site.
- **Centralized and scalable** — Manage all your redirects in one place with version control.
- **No HTML clutter** — No need to generate placeholder HTML pages just to jump somewhere else.

### My Use Case

Now I use this method for:

- `/book` → Calendly
- `/github` → My GitHub profile
- `/linkedin` → My LinkedIn
- And more to come...

It’s simple, effective, and makes it easier to share my links without remembering long URLs.

—

If you’re deploying a Hugo site on Netlify and struggling with Hugo’s redirects, I *highly* recommend switching to the `netlify.toml` approach. It’s flexible, intuitive, and just works.

Let me know if you want to see my full Netlify config or need help setting yours up!