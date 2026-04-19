---
title: "Service Generator: Building a ProPresenter Playlist From a PDF Service Order"
date: 2026-03-24T10:00:00Z
draft: true
hero: images/posts/propresenter-service-generator/hero.svg
description: "How Service Generator turns a Planning Center PDF into a fully-populated ProPresenter playlist in about two minutes — and the song-title fuzzy-matching problem that almost killed it."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A ProPresenter playlist being built from a service order PDF"
tags: ["propresenter", "typescript", "electron", "church-tech", "planning-center", "open-source"]
categories: ["Projects", "Church Tech"]
summary: "How Service Generator turns a Planning Center PDF into a fully-populated ProPresenter playlist in about two minutes — and the song-title fuzzy-matching problem that almost killed it."
---

> This is a follow-up to [Building ProPresenter Lyrics Export]({{< ref "/posts/propresenter-lyrics-export" >}}), which covers the broader tool. This post is specifically about the Service Generator feature — what it does, how it works, and why step 3 was harder than it looked.

## The 20-minute Sunday-morning tax

Every week a volunteer (or, honestly, a bleary Saturday-night me) opens the service order PDF from Planning Center, opens ProPresenter, and spends 15–20 minutes building a playlist by hand:

- Drag each song from the worship library in the right order.
- Find the Bible passages referenced in the sermon and drop them in.
- Slot in the kids' songs from a different library.
- Match announcements to the running order.
- Double-check nothing's missing before the first service.

It's not hard. It's just tedious, and it's the kind of task where you only notice the mistake once the band is already playing.

**Service Generator** is my attempt to remove that tax. You feed it the PDF, and it builds the ProPresenter playlist for you — usually in about two minutes, with a human in the loop at the only step that actually needs judgement.

> 📦 **Repo:** [github.com/adamswbrown/propresenterlyricexport](https://github.com/adamswbrown/propresenterlyricexport)
> 📖 **Guide:** [Service Generator Guide](https://adamswbrown.github.io/propresenterlyricexport/guides/service-generator)

## What the feature actually does

You give Service Generator a PDF service order — from Planning Center, Proclaim, ChurchPlanner, or anything with a reasonably structured running order — and it populates your target ProPresenter playlist automatically with:

- **Song items** matched against your worship library.
- **Bible passages** linked to the right presentations in your service-content library, so "John 3:16" points at *your* John 3:16 presentation rather than a generic one.
- **Kids content** pulled from a separate kids library and categorised properly.
- **Service structure and announcements** slotted into the running order where the PDF says they should go.

The whole flow is in the Electron desktop app. CLI users still get the core lyrics-export workflow; Service Generator is a GUI-only feature because the review step in the middle matters too much to skip.

## The six-step workflow

**1. One-time setup.** Tell Service Generator which ProPresenter libraries are your worship library, your kids library, and your service-content library, plus which playlist folder you want generated services dropped into. This gets saved locally so you don't do it again. (You do need to create a playlist folder in ProPresenter first — right-click in the Playlists panel and call it something like "Services" or "Weekly Services".)

**2. Upload the PDF.** Drag-and-drop the service order. The app parses it, extracts the running order, and identifies song titles, Bible references, announcement blocks, and kids items.

**3. Confirm or correct the matches.** This is the step that matters. Every song title the PDF mentions gets fuzzy-matched against your ProPresenter library, and the app shows you its best guess plus confidence-ranked alternatives. You confirm, override, or flag "this song doesn't exist yet." Nothing gets written to ProPresenter until you say yes.

**4. Resolve Bible passages.** References from the PDF get matched against the presentations already in your service-content library. Again, human-in-the-loop: you can override any match before commit.

**5. Preview the running order.** Full preview on screen with every slide in position before anything touches ProPresenter.

**6. Generate.** The playlist gets built inside your chosen folder. Done. Ready for Sunday.

The whole thing usually takes two to three minutes end-to-end. The setup is five minutes, once.

## The hard bit: fuzzy-matching a real worship library

Step 3 is where the design choice actually matters, and it's the step that almost killed the feature before it shipped.

Worship libraries are messy. A library that's been in use for a decade accumulates seven variants of *"How Great Thou Art"* — some with typos, some with a year appended, some in a different key, some with slightly different arrangements. And the PDF will call the song whatever the worship leader typed into Planning Center *that week*, which might bear only a loose resemblance to any of the library entries.

A naive exact-match lookup finds nothing. A naive fuzzy match finds the wrong thing confidently and silently, which is worse.

The approach that ended up working:

- **Normalise aggressively.** Lowercase, strip punctuation, collapse whitespace, normalise unicode quotes, strip common prefixes like "The", strip trailing keys/versions like "(G)" or "v2".
- **Score multiple candidates.** Token-set ratio plus partial-ratio plus a first-word match bonus, combined into a single confidence score.
- **Cap the auto-pick.** Below a threshold, Service Generator refuses to auto-select — it presents the top N alternatives and makes you choose. Above the threshold, it picks but still shows the alternatives for a quick visual confirmation.
- **Surface uncertainty loudly.** Low-confidence matches get a warning badge. "Doesn't exist in library" gets its own state so you can add the song to ProPresenter and retry, rather than the app pretending it found something.

The insight wasn't the algorithm. It was accepting that a worship volunteer spending ten seconds confirming a match is dramatically cheaper than spending Sunday morning discovering the wrong song made it into the playlist.

## Plan Service: the pre-planning variant

Not every church works from a PDF on Saturday night. Some plan services weeks in advance, straight into ProPresenter. For those workflows there's a **Plan Service** variant of the same core engine:

1. Define a service template once (opening, song, announcements, kids, sermon, song, closing — whatever your running order looks like).
2. Assign songs to slots ahead of time, either manually or by pulling from ChurchSuite.
3. When the date rolls around, Plan Service builds the playlist from the template — no PDF required.

Same matching engine, same review step, different upstream input. Useful if you want to plan the whole quarter's worship on a whim-free Tuesday afternoon instead of a panicked Saturday night.

## What I'd change

**More CI on the parser.** PDF extraction is unforgiving — Planning Center changed a section header once and it broke matching for a week. More structured tests against real PDFs would have caught it earlier.

**Better library caching.** First run on a 500-song library has a perceptible "is it thinking or is it broken?" pause while it indexes. Fixable with a background prefetch.

**A CLI version for the church IT crowd.** Not a priority for me but PRs welcome if you want to run this from a scheduled task.

## If this is useful to you

Service Generator is open source and free. If your worship team is doing the 20-minute tax every week, give it a try — and please open issues, because every church's library is weird in its own specific way and each one teaches the matcher something new.
