---
title: "Briefing Builder"
date: 2026-05-28
draft: false
description: "A Claude skill that interviews you, then generates your own custom morning-briefing and call-prep skills wired to the tools you actually use."
icon: fa-solid fa-mug-hot
category: Claude Skill
version: "1.0"
weight: 1
file: /files/downloads/briefing-builder.skill
---

Most "daily briefing" skills assume you use the same stack as whoever wrote them.
Briefing Builder doesn't. It's a meta-skill: it interviews you about your tools,
role, and what "important" actually means to you — then generates a pair of
briefing skills tailored to your setup.

There's a full write-up of why I built it on the blog:
[The Briefing Skill That Builds Itself Around You](/posts/briefing-builder-skill/).

## What it does

Run it once and it walks you through a short set of questions, then produces two
ready-to-install skills:

- **Morning briefing** — what happened overnight across your email and chat, sorted by what matters to *you*.
- **Call prep** — account context, attendee research, and a suggested agenda before each meeting.

## How it adapts

- **Your tools drive the sources.** Gmail vs Outlook, Slack vs Teams, Google Calendar vs Notion vs Cal.com — each is handled differently, and anything you don't have is gracefully skipped. No connectors at all? It falls back to web search and whatever you paste in.
- **Your role drives the priorities.** "Urgent" means incidents and blocked PRs for an engineer, hot deals and prospect replies for sales, investor comms and churn signals for a founder. Your own definition of high-priority overrides all of it.
- **Your meeting volume drives the length.** Three calls a day gets you full account snapshots and agendas; ten calls a day gets you tight open-threads-and-names checklists.

## How to use it

1. Download the `.skill` file below.
2. Install it (drop it in your skills directory / import it in Claude).
3. Run it and answer the questions — it generates your two custom skills.
4. Optionally set them up as scheduled tasks so the briefing lands every morning.
