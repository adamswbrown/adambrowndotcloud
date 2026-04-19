---
title: "Building Tour of the Bible: A 66-Book Reading Companion with No Backend"
date: 2026-04-12T10:00:00Z
draft: false
hero: images/posts/building-bible-tour/hero.svg
description: "A web companion for Matt Whitman's 'Lightning-Fast Field Guide to the Bible' — track your progress through all 66 books with curated verse references, no accounts, no database."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "An open Bible with a checklist overlay tracking reading progress"
tags: ["nextjs", "vercel", "bible", "side-project", "no-backend"]
categories: ["Projects", "Faith"]
---

## Why I built it

Matt Whitman — the "Ten Minute Bible Hour" guy — wrote a short piece called the *Lightning-Fast Field Guide to the Bible*: 66 books, roughly 90 minutes, a couple of key passages per book to give you the taste without the full commitment. I loved the idea. I wanted a cleaner way to work through it than a physical checklist and a notes app, with the passages *right there* to tap on rather than switching to a Bible app and losing my place.

So I built one. Not affiliated with or endorsed by The Ten Minute Bible Hour — just a fan-built companion.

> 🌍 **Live:** [bible-tour.vercel.app](https://bible-tour.vercel.app)
> 📦 **Repo:** [github.com/adamswbrown/bible-tour](https://github.com/adamswbrown/bible-tour)

## What it does

- A checklist across all 66 books with curated key-verse references for each.
- An inline verse reader — tap any reference and the passage loads in a panel without leaving the app.
- Multiple translations: **NIV, NIrV, NIVUK** (via YouVersion's Developer API) and **KJV, WEB, ASV** (via the public-domain [bible-api.com](https://bible-api.com)).
- Progress lives in `localStorage`. No accounts. No database. No tracking. Close the tab, come back next week, your progress is still there.

## The architecture decision that mattered most

**No backend.** Or, more accurately: the only server-side code is a single API route that proxies requests to YouVersion so the API key never reaches the browser. Everything else — the checklist, the progress, the verse caching — is client-side.

This was deliberate. A project like this shouldn't require me to run a database, rotate credentials, or think about GDPR. A static Next.js app on Vercel with one tiny edge function is all it needs to be, and it means the whole thing costs pennies to run and zero minutes to maintain.

## What I added later

The fun of a side project is that you keep finding features you want:

- **Study Mode (rebranded to "Originals")** — a deeper mode that shows Greek/Hebrew lemma data inline, powered by the [STEPBible lexicon](https://github.com/STEPBible/STEPBible-Data). Building this meant writing a data-pipeline script to prune the STEPBible lexicon into something web-shippable, plus tagging every verse with its underlying lemmas. The UI is a `WordPopover` and a `LexiconDrawer`; tap a word, see what it is in the original language.
- **Eagle view** — a second reading track for folks who want a different pacing.
- **Feedback button** — a floating button that opens a pre-filled email. Easier than a form and harder to abuse.

## Things I learned

**YouVersion's developer platform is great, if you can get in.** Licensed translations (NIV, NIrV, NIVUK) are only legally available via their API, and you have to apply for access. The free public-domain translations via bible-api.com fill the gap for anyone who can't.

**`localStorage` is underrated.** For single-user, device-local state, you don't need Redux, you don't need a sync server, you don't need accounts. A `useState` + `useEffect` pair reading and writing a JSON blob is genuinely all that's required.

**Scope is a feature.** It would be very easy to add accounts, sync, social sharing, notifications. None of them would make this thing better at its one job.

Feel free to fork, file issues, or propose passages I missed.
