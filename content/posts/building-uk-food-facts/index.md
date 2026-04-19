---
title: "Building UK Food Facts: From 'How Many Calories in a Sausage Roll' to 2,700 Meals"
date: 2026-04-19T10:00:00Z
draft: false
hero: images/posts/building-uk-food-facts/hero.svg
description: "I spent 20 minutes trying to find the calories in a Greggs sausage roll and ended up building a whole app."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A restaurant nutrition table with meals colour-coded by calorie count"
tags: ["python", "playwright", "github-actions", "vercel", "scraping", "side-project", "open-source"]
categories: ["Projects", "Tech"]
summary: "I spent 20 minutes trying to find the calories in a Greggs sausage roll and ended up building a whole app."
---

I spent 20 minutes trying to find the calories in a Greggs sausage roll and ended up building a whole app.

> 🌍 **Live:** [uk-calories.vercel.app](https://uk-calories.vercel.app)
> 📦 **Repo:** [github.com/adamswbrown/ukfoodfacts](https://github.com/adamswbrown/ukfoodfacts)

## Why this exists

I'm working on a fitness app as a side project, and I needed restaurant calorie data for it. Packaged food was easy — there are plenty of free APIs for that. Open Food Facts, Edamam, the usual suspects. You scan a barcode, you get back macros. Solved problem.

Restaurants were not a solved problem.

The few nutrition APIs that do cover restaurants are almost all US-focused. Nutritionix has good coverage of American chains and essentially nothing for the UK. The others either don't exist or want enterprise contracts for data that shouldn't really be gated in the first place.

Then I realised the obvious thing: **restaurants already publish this data.** In the UK, the large chains are legally required to display calorie information. It's already on their websites. It's just scattered across dozens of sites, in dozens of formats, with no common schema.

So I built **UK Food Facts.**

## What it is

A web app that pulls nutrition data from 150+ restaurant chains across the UK, Ireland, Australia, and New Zealand, plus local spots in Bangor and Belfast where I live. At time of writing: **2,735 menu items, 168 restaurants.** Every item has calories, protein, carbs, fat, fibre, salt, allergens, dietary flags, and a source URL back to whichever page the data came from.

The UI does the unglamorous-but-useful stuff:

- Search across restaurants, dishes, and locations.
- Filter by chain, by region, by category.
- Sort by any column (calories, protein, and so on).
- **Colour-coded calories:** green under 400, amber 400–699, red 700+. You can tell at a glance whether that burger is a green light or a red flag.
- Detail modal with the full macro breakdown.
- Add your own meals and tag them by location.

It auto-detects your country by geolocation and cascades the filter, so a user in Melbourne doesn't have to scroll past 70 UK chains to find Guzman y Gomez.

## The bit I'm most pleased with

The data is not static. A **GitHub Action runs daily**, executes the scrapers, commits the fresh nutrition data back to the repo, and Vercel auto-redeploys from the new commit. No manual updates, no stale numbers, no cron job on a box somewhere that I forget to renew.

Commits from the workflow look like this:

```
chore: update nutrition data 2026-04-15 — 2735 items, 168 restaurants
chore: update nutrition data 2026-04-11 — 2735 items, 168 restaurants
chore: update nutrition data 2026-04-10 — 2733 items, 168 restaurants
```

That's the entire operational overhead. I don't log in. I don't run anything. The app just stays fresh.

The only scraper with any real nuance is **Wagamama**. Their menu is rendered client-side in JavaScript, so a plain HTTP request returns an empty shell. The Wagamama job uses Playwright to spin up a headless Chromium, wait for the menu to render, then extract the data. Wagamama is the reason that scraper exists — they started this particular fight. Everyone else fell to regular HTTP + HTML parsing.

## User-submitted meals

The LinkedIn comments on this project kept landing on the same request: *"Can you add [local chain nobody's heard of outside their county]?"* Rather than becoming the bottleneck, I wired up a submission path that reuses GitHub's infrastructure:

1. A user fills in the "Add a meal" form in the UI.
2. The UI creates a **GitHub Issue** with the meal details in a structured format.
3. I review the issue. If it's valid, I close it.
4. A **second GitHub Action** watches for closed issues with the `meal-submission` label, parses the data, commits it to the custom-meals JSON, and Vercel redeploys.

So "approve a meal" is literally me clicking Close on a GitHub issue on my phone. No custom admin panel. No database write flow. The contribution mechanic piggy-backs on tools I was going to have open anyway.

This is the kind of workflow that used to feel like over-engineering and now feels completely natural. GitHub is the database. Vercel is the deploy pipeline. Actions is the back-end. The app is a thin Flask layer with some HTML.

## Stack, in one line

**Python** for scrapers, **Playwright** for the JS-rendered stragglers, **Flask** for the web app, **GitHub Actions** for scheduling and user-submission handling, **Vercel** for hosting. All open source.

## What I'd do differently

**Schema validation earlier.** The first few scrapers wrote slightly different shapes to JSON and I only caught it when the UI choked on a missing `salt_g` field. A [Pydantic](https://docs.pydantic.dev/) model in the middle would have caught that at scrape time.

**One scraper per file was the right call.** Every chain's website is a snowflake, so the per-scraper file pattern (`scrapers/nandos.py`, `scrapers/wagamama.py`, `scrapers/mcdonalds.py`) keeps blast radius tight. When Wagamama redesigns their menu — and they will — I fix one file.

**Fallback data matters.** Every scraper has a hand-curated fallback it uses when the live scrape fails. That's the difference between "the site looks broken today" and "the site gently ages." Graceful degradation, not a stack trace.

## Have a look

The live app is at [uk-calories.vercel.app](https://uk-calories.vercel.app). The code is open source at [github.com/adamswbrown/ukfoodfacts](https://github.com/adamswbrown/ukfoodfacts). Pull requests for new chains are very welcome — especially if you know a local place in your city that publishes their nutrition data and nobody's indexed it yet.

It started as a 20-minute sausage-roll search. It became 2,700 meals updating themselves daily. That's the shape of these projects, lately.
