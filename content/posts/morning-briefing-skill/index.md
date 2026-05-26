---
title: "The Morning Briefing I Don't Have to Write"
date: 2026-05-26T08:00:00Z
draft: false
description: "A Claude skill that reads Gmail, Outlook, Teams, and my calendar so I don't have to. Twenty minutes of inbox archaeology, gone."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: ["claude", "automation", "productivity", "notion", "skills"]
categories: ["Projects", "Productivity"]
---

Every morning starts the same way. Coffee, desk, the slow dread of opening four different surfaces to figure out what I missed. Gmail for personal. Outlook for work. Teams for whatever the team was arguing about in the Workflows chat at 11pm. And the calendar, because none of that matters if I'm walking into a meeting I forgot about in twenty minutes.

Doing that reading manually takes about twenty minutes. Most of it is junk. The handful of things that actually matter are buried somewhere between a "FYI" message and an Apple developer notification I should have read three days ago.

So I built a skill that does the reading for me.

## What it actually does

The morning-briefing skill is a manual trigger. I sit down, unlock my Mac, type "morning briefing" into Claude, and walk away to refill the cup. By the time I'm back, I have a structured summary on screen telling me what came in overnight, what's on the calendar today, and what needs my attention before the first call.

It pulls from four sources:

1. **Today's meetings** — from the Meeting Reminder Notion database
2. **Gmail** — via the Gmail MCP connector
3. **Outlook** — the new Outlook for Mac, read via computer control
4. **Teams** — also via computer control, Activity feed and the Workflows chat

The skill runs them in roughly that order. Meetings first, because the rest of the briefing is more useful when I already know what the day looks like.

## Meetings come from Notion, not Outlook

This is the part most people get wrong when they hear about the briefing. They assume meetings are read out of Outlook, the way the email and Teams sections are. They are not.

Meetings come from a Notion database called `Calendar Events`, which is populated by a separate Mac app I built called [Meeting Reminder](/posts/building-meeting-reminder/). Meeting Reminder runs a calendar-to-Notion sync every morning at 06:00, plus on demand from the menu bar. 90 days back, 30 days forward. Recurring events get one row per occurrence, keyed by `<external_id>_<YYYY-MM-DD>` in Europe/London time so a 23:30 BST event doesn't collide with tomorrow's occurrence. Cancelled events get archived. Manually-edited rows are kept around as `Stale` rather than deleted, so I never lose notes attached to a row.

By the time the briefing skill runs at 7am-ish, the calendar is already in Notion. The briefing just queries today's rows, pulls the linked Pre-Call Briefings if there are any, and lists out the day in order. No screen scraping, no EventKit, no Outlook quirks. It's an API call against a database that already has everything in it.

The reason this matters is reliability. Reading meetings out of Outlook via computer control is fine until Outlook is slow to load, or my screen is locked, or there's a modal dialog covering the calendar view. Reading them out of Notion is an HTTP GET. It either works or it tells me why it didn't.

## The other three sources

Gmail is the easy one. The Gmail MCP gives me `gmail_search_messages` and I just query for anything newer than 24 hours. Anything from Apple, App Store Connect, or developer-related senders gets read in full — those are the messages I cannot afford to miss. Everything else gets a one-line sender + subject summary.

Outlook is harder, because there's no good public API for the new Outlook for Mac. So the skill opens the app via computer control, takes a screenshot, scrolls through, and reads what came in since 5pm yesterday. Action items first, FYI second.

Teams is the same shape as Outlook. Open it, screenshot, check the Activity feed for @mentions, then check the Workflows chat for anything posted overnight. Group by source, flag anything that needs a response.

The only requirement for the computer-control parts is an unlocked Mac. If the screen is locked, the skill knows to skip Outlook and Teams and run Notion + Gmail only, then tell me what it couldn't reach.

## The output

I told the skill to format the briefing in a specific shape, because the whole point is scanning. So every morning I get back something like:

```
Good morning! Here's what happened overnight, and what's on today:

Today's Meetings (5)
- 09:30 — Sync with Partner X (brief: open thread on Q3 forecast)
- 11:00 — Demo with [Prospect] (brief: technical eval, CTO joining)
- 14:00 — Internal: roadmap review
- 16:00 — 1:1 with [Manager]
- 17:30 — Ad-hoc holding slot (no description)

Gmail
- App Store Connect: review on [app] — 4 stars, no issues
- Stripe: payment received from [customer]
- 3 promo emails (ignored)

Outlook
- Action: [Partner] needs a response on Q3 forecast by EOD
- FYI: Engineering pushed the release to Thursday

Teams
- @mention from [colleague] in #workflows re: the migration script
- 2 messages in Workflows chat about the partner onboarding flow

Action Items
1. Reply to [Partner] on Q3 forecast (before 09:30 call lands on it)
2. Answer [colleague]'s migration script question
3. Read the 11:00 pre-call briefing before the demo
```

Two minutes to read. Five minutes to triage. The rest of the morning is actual work instead of inbox archaeology.

## What I changed after using it for a while

The first version of this skill summarised everything. Every email. Every message. Every meeting line item. The output was a wall of text I still had to read carefully, which defeated the point.

So I rewrote it to be opinionated. Apple emails get read in full. Everything else is sender + subject. Outlook action items go first, FYI second. Teams mentions go first because someone actually wanted my attention there. Meetings get a one-line description plus a flag if there's a pre-call briefing already written for them by the 07:00 scheduled task.

The consolidated `Action Items` block at the bottom is the only part I actually need to read most days. Everything above it is context if I want to dig in.

## What it's not

This is not the sales daily briefing — that's a different skill, focused on pipeline. The morning briefing is operational. What landed overnight, what's on today, what needs a response before the first meeting.

It's also not trying to replace any of the underlying apps. I still read the messages that matter. The skill just does the first pass for me, so I'm not reading promo newsletters and "thanks!" replies with the same attention I give to a partner asking for a decision.

## The compounding bit

The thing I didn't predict is how this changed my evenings. When I trusted that the morning briefing would catch anything important, I stopped checking my phone at 10pm. I stopped opening Outlook after dinner. The overnight queue can wait, because I know it'll be triaged for me at 7am, with the day already laid out next to it.

That's the actual win. Not the twenty minutes I save reading. It's the four or five hours of evening I get back, because I'm not pre-reading my morning at midnight.

If you've got Claude, computer control, three communication apps, and a calendar you'd rather not screen-scrape, the skill takes about an hour to set up. I'd build it again tomorrow.
