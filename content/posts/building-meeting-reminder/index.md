---
title: "Building Meeting Reminder: An ADHD-Focused Menu Bar App for macOS"
date: 2026-04-10T10:00:00Z
draft: false
hero: images/posts/building-meeting-reminder/hero.svg
description: "What started as a free alternative to In Your Face became an ADHD-focused meeting assistant with progressive alerts, Notion integration, and hybrid meeting-end detection."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A macOS menu bar showing a meeting countdown"
tags: ["swift", "macos", "adhd", "productivity", "open-source", "notion"]
categories: ["Projects", "Productivity"]
---

## The problem

I lose track of time. Not in a cute "oh wow, 3pm already" way — in a "the meeting started 4 minutes ago and nobody's in the room but me and confusion" way. Calendar notifications are too quiet. Slack DMs asking "you joining?" are too late. And the moment I'm deep in a document or a terminal, the rest of the world stops existing.

I'd been using [In Your Face](https://www.inyourface.app) for a while — a brilliant macOS app that throws a full-screen block in front of you before meetings. It's excellent. But I wanted to tinker, I wanted something free and open source, and I wanted to layer in a few things specific to how *my* brain misses meetings.

That tinkering became **Meeting Reminder**.

> 📦 **Repo:** [github.com/adamswbrown/meeting-reminder](https://github.com/adamswbrown/meeting-reminder)

## What it does

The core is simple: read your calendar, show a countdown in the menu bar, escalate alerts as the meeting approaches, and throw a full-screen overlay in front of you at a configurable lead time. One-click join detects Zoom, Google Meet, Teams, Webex, and Slack Huddle links automatically.

But the bits I actually *built this for* are the time-blindness features:

- **Persistent countdown in the menu bar** — `"Standup in 12m"` — updates every 10 seconds as the meeting approaches. No clicking, no hovering, just there.
- **Colour-coded icon** that shifts green → yellow → orange → red with distinct SF Symbol shapes per tier (for colour-blind friendliness and glanceability).
- **Wrap-up nudge** — the menu bar text changes to `"Wrap up — Standup in 12m"` at a configurable threshold. That single word reframes the next few minutes from "I have time" to "I need to land this plane."
- **Progressive alerts** that get louder, bigger, more insistent as the meeting gets closer.

## The Notion integration I didn't plan

At some point I realised I also kept forgetting to take notes. Or I'd take notes in a different place each time. So I added an optional Notion integration: when you join a meeting, the app creates a page in a Notion meeting database automatically. Notion's AI Meeting Notes handles recording and summarisation from there.

This turned out to be the feature I use most. Getting it right took more iteration than I expected — the Notion API has a 2000-character limit per block, so I had to split long calendar notes across multiple paragraph blocks. Meeting descriptions from Teams and Zoom invites contain a wall of video-join boilerplate that had to be stripped. And I hit a nasty race condition where clicking the Notion link before the page creation finished would open a second copy of the page — solved with a per-event deduplication guard.

## Things I'd do differently

- **Meeting-end detection is hard.** Calendars say the meeting ends at 11:00. The meeting sometimes ends at 10:47. Sometimes 11:14. I ended up with a hybrid approach — calendar time *plus* detection of the video app's window state — and it mostly works.
- **Services didn't start until the first popover click.** Obvious in hindsight, but I had a fun evening figuring that out. Menu bar apps have a specific lifecycle that's worth reading the Apple docs on before you write your own.

## What's next

The [CHANGELOG](https://github.com/adamswbrown/meeting-reminder/blob/main/CHANGELOG.md) is the most honest roadmap. Open to PRs and issues if any of this is useful to you.
