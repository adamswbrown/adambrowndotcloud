---
title: "Two Skills, One Notion: The Operations Hub Behind My Morning"
date: 2026-05-28T09:00:00Z
draft: false
description: "The morning-briefing skill and the pre-call-brief skill don't share much code. They share a Notion schema. This is the schema."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: ["claude", "automation", "productivity", "notion", "skills"]
categories: ["Projects", "Productivity"]
---

I've written about two skills in the last couple of weeks. The [morning briefing](/posts/morning-briefing-skill/) one that reads Gmail, Outlook, Teams and my calendar so I don't have to. The [pre-call brief](/posts/pre-call-brief-skill/) one that writes a context page for every meeting on my calendar before I sit down. Both posts mentioned Notion, mostly in passing, as the place the calendar lives.

A friend asked me last week what that actually looked like. He'd built the pre-call skill from the post, pointed it at a single-table Notion database, and watched it produce briefs that were missing half the context he expected. The skill wasn't the problem. The Notion underneath it was.

So this post is the missing middle. The Notion structure that makes both skills useful, and the half-dozen design decisions that look small but turn out to matter once you live with them. If you're trying to build something similar, this is the bit nobody writes down.

## The shape, in one picture

Everything lives under a single page called **Operations**. It's deliberately boring. No dashboards, no widgets, no aesthetic. A short intro paragraph and then the databases and settings pages it owns:

```text
⚙️ Operations
├── 📅 Calendar Events       (database — canonical, synced daily)
├── 📝 Pre-Call Briefings    (database — sparse, written by skill)
├── 🗒️ Meeting Notes         (database — sparse, written by me)
├── ⚙️ Daily Briefing Settings  (page — working hours, run log, skip list)
└── 🗺️ Customer / Partner Mapping Rules  (page + database — domain/title → customer)
```

The thing worth saying out loud before going deeper: **Calendar Events is dense, the other two are sparse.** Every meeting on my Apple calendar gets a row in Calendar Events, whether it matters or not. Meeting Notes and Pre-Call Briefings only exist for meetings that warrant them. They relate back to Calendar Events, never the other way round.

The first version of this had it backwards. Meeting Notes was the spine and the calendar fed into it. It was awful. Half my meetings don't warrant notes, so the spine had holes in it. The calendar had to be queried twice — once to know what was happening, once to find the orphan events that didn't have notes yet. Inverting it fixed everything. Calendar Events is the ledger. Everything else is an opt-in attachment.

## Calendar Events: the bit that has to be right

This is the database that gets hit every morning. The morning briefing reads it for today's meetings. The pre-call skill walks tomorrow's rows to know what to write. Meeting Reminder, my menu-bar app, watches it for "starts in five minutes" alerts. If this database is wrong, everything downstream is wrong.

The schema, simplified to the columns that earn their keep:

| Column | Type | Why it's there |
|---|---|---|
| `Title` | title | Obvious. |
| `Date` | date (with time) | Start and end. |
| `Status` | select | `Upcoming` / `Today` / `Past` / `Cancelled`. Derived at sync time. |
| `Apple Event ID` | text | **Unique upsert key.** UUID for one-offs, `{master_uuid}_{ISO_date}` for recurring occurrences. |
| `iCal UID` | text | Cross-system event ID — matches Outlook/Google ICS UIDs. |
| `Recurring` | checkbox | True if part of a series. |
| `Series Master` | checkbox | True for the series definition row, false for occurrences. |
| `All Day` | checkbox | Distinguishes holidays/OOO from actual meetings. |
| `Attendees` | text | Pipe-separated: `Name <email> \| Name <email>`. |
| `Attendee Count` | number | Excludes the organiser. |
| `Has External Attendees` | checkbox | True if any attendee domain is not `@altra.cloud`. |
| `Conference URL` | url | Teams/Zoom/Meet link, extracted from the body. |
| `Organiser` | text | Display name. |
| `Description` | text | Event body, truncated to ~2000 chars. |
| `Availability` | select | `Busy` / `Free` / `Tentative` / `OOO` / `Unknown`. |
| `Sync State` | select | `Active` / `Stale` / `Orphaned`. Lets me keep manually-edited rows around when the calendar deletes them. |
| `Last Synced` | date | Timestamp of the last sync that touched this row. |
| `Pre-Call Briefing` | relation | Optional link out to a brief. |
| `Meeting Notes` | relation | Optional link out to notes. |

Four columns are doing more work than they look like they're doing. They deserve the rest of this section.

### `Apple Event ID` — the upsert key

The whole sync stands on this. The temptation when you're building a calendar sync is to upsert on `iCal UID`. Don't. A recurring meeting has one UID and N occurrences. If you key on UID, every sync collapses the series into a single row and you lose the per-occurrence notes.

So Apple Event ID is `{master_uuid}_{ISO_date}` for series occurrences, and just the raw UUID for one-offs. The date is in Europe/London time, not UTC, because otherwise a 23:30 BST event collides with tomorrow's occurrence and you start losing rows in the worst possible way — silently. It took me two weeks of "where did Tuesday go?" to find that bug.

### `Has External Attendees` — the filter that runs every query

`@altra.cloud` is my work domain. Any meeting where every attendee email ends in `@altra.cloud` is an internal sync, and most days I don't need a pre-call brief for "Internal: roadmap chat." So this checkbox is computed at sync time, and the pre-call skill uses it as a first-pass filter. Without it, I get briefs for every standup and water-cooler chat.

It also drives the **Customer-Facing** view I use to see what's happening with external accounts this week. Two clicks to a clean list of every customer/partner meeting on the books. No filtering, no sorting, no clever queries.

### `Sync State` — keeping ghosts around on purpose

`Active` means the calendar still has it. `Stale` means the calendar still has it but I edited the row by hand and didn't want the sync to clobber my edit. `Orphaned` means the calendar deleted it but I'm not ready to lose the linked notes.

I almost skipped this column when I built the schema. I thought I'd never edit a synced row. I was wrong within a week — I'd routinely fix attendee names, add a Customer/Partner tag, drop a sentence into the description. Without `Sync State`, the next sync would overwrite all of that. With it, the sync skips any row marked Stale and tells me about it in the run log. Quiet, recoverable, no surprises.

### `Pre-Call Briefing` and `Meeting Notes` — the opt-in spine

Two relations, pointing out to the sparse layers. The skill creates Pre-Call Briefings and links them. I create Meeting Notes manually after the call and link them. Either relation is empty most of the time, and that's fine — that's the design.

The relation also gives me the inverse view for free: open a Meeting Notes page and you can see exactly which calendar event it came from. Open a Pre-Call Briefing page and you can see what the call ended up being.

## The views that earn their keep

The database is wide. The views are narrow. I have a small handful that I actually use, and they're the ones that constrain the schema's verbosity into something a human wants to look at:

- **Today** — `Status = Today AND All Day = false AND Series Master = false`. Sorted by Date ascending. This is the view the morning briefing reads. Also the view I leave open in a tab.
- **This Week** — Date range filter on the current week. Grouped by relative date. This is what I look at on Monday morning to know what the week is.
- **Upcoming** — `Status = Upcoming`. The pre-call skill walks this view.
- **Customer-Facing** — `Has External Attendees = true`. The view I share when someone asks "what's on with [Customer] this week?"
- **Calendar** — the actual calendar view, Notion's `calendarBy: Date`. Almost never useful, but occasionally I want to drag a meeting onto a different day without opening Apple Calendar. It pays for itself once a quarter.

The trick with Notion views is that they don't cost much to make and don't cost anything to ignore. The default view is the kitchen-sink one with every column. I add a focused view every time I find myself manually filtering for the same thing twice.

## Pre-Call Briefings: the database the skill writes into

This is where the pre-call brief skill drops its output. It's narrower than Calendar Events because most of the *content* of a brief lives in the page body, not the properties. The properties are there for filtering and rollup.

| Column | Type | Notes |
|---|---|---|
| `Meeting Title` | title | Same as the calendar event. |
| `Date & Time` | date | Copied from the calendar row at write time. |
| `Attendees` | text | Plain text — the skill doesn't try to match people to a contact DB. |
| `Customer / Partner` | select | One of ~35 canonical options (Hays, Heathrow, M&S, KPMG, etc.). |
| `Stage` | select | `Discovery` / `Scoping` / `Pilot` / `Active` / `Review` / `Partner Enablement` / `New Partner Kickoff`. |
| `Briefing Status` | select | `Auto` / `Reviewed` / `Skipped`. |
| `Meeting Outcome` | select | `Happened` / `Cancelled` / `Postponed` / `No-Show`. Filled in after the call. |
| `New Contact?` | checkbox | Flags briefs where at least one attendee is new to me. |
| `Calendar Event` | relation | Back to the row that spawned this brief. |
| `Prior Meetings` | relation | Links to relevant prior Meeting Notes. |

A few of these are worth pulling out.

**`Customer / Partner` is a select, not a relation.** I went back and forth on this one. The "right" answer in Notion is to relate Pre-Call Briefings to a Customers database. The pragmatic answer is that I don't have a Customers database — Engagement Tracker is close, but it's per-engagement, not per-account. So Customer / Partner is a flat select with ~35 options, and a separate Mapping Rules database is what the skill consults to figure out which option to assign.

This trade-off costs me one thing: when a new partner appears, I have to add the select option in this DB *and* a mapping rule. If I forget the first step, the briefing-create call fails. That failure shows up in the run log within an hour, so the worst case is one missed brief. Acceptable.

**`Stage` is for me, not the skill.** The skill never sets Stage. I set it after I've read the brief and reviewed where the account is. It's the column that turns the database into a portfolio view — three minutes filtering on `Stage = Active` tells me what's actually moving.

**`Briefing Status` is the skill's own state machine.** Every row starts as `Auto`. I flip it to `Reviewed` once I've read the brief and added my own notes on top. If I decide the brief isn't worth keeping, I flip to `Skipped`. The skill never touches a row that's been moved out of `Auto`, so my edits stick.

**`Prior Meetings`** is the one that makes the brief actually good. Every brief points at the relevant Meeting Notes from previous calls — not just for the same customer, but specifically the threads the skill thinks are live. When that relation is populated, the brief reads like "here's where we left off." When it's empty, the brief reads like a Wikipedia page about the customer.

## Meeting Notes: my side of the contract

This is the database I write into. The skill never touches it. It's also the sparsest of the three — maybe a third of my calendar events end up with notes attached.

The schema is mostly date columns (Start, End, Date, Duration), people fields (Notetaker, Participants), and two categorical bits that I find myself using a lot:

- **`Category`** — `Discovery / Qualification`, `Business Case / Value Modelling`, `Implementation / Technical Working Session`, `Internal Planning / Strategy`, `Customer Check‑in / QBR`, `Commercial / Pricing / Contract`, `Support / Issue Resolution`, `Other`. This is the cell I tag during the call, not after. It's faster than writing a paragraph, and it makes the analytics view useful at the end of the quarter ("how many discovery sessions did I actually run in Q1?").
- **`Action Items`** — a free-text column for the things I committed to. The pre-call brief skill reads this column when it builds a brief for the *next* meeting with the same customer. So an Action Item I drop here on Tuesday is what the skill reminds me about on Friday morning. This is the loop that makes the whole thing self-improving.

The relation back to `Calendar Event` is what lets the skill find these notes when it's writing tomorrow's brief. Without that link, the notes are just notes — useful when I open them, invisible to the automation.

## Daily Briefing Settings: the bit I edit, the skill reads

Most of the people I've shown this to expect the skill's configuration to live in code. It doesn't. It lives in a Notion page called **Daily Briefing Settings**, with the working hours in a regular Notion table:

| Day | Start | End |
|---|---|---|
| Monday | 08:30 | 17:00 |
| Tuesday | 08:30 | 17:45 |
| Wednesday | 08:30 | 17:00 |
| Thursday | 08:30 | 17:00 |
| Friday | 08:30 | 17:00 |
| Saturday | — | — |
| Sunday | — | — |

The skill reads this table at run time. If a day's row has `—` in both columns, the day is "off" and the skill skips free-block detection. If I'm doing an early start on Tuesday, I edit the table on Monday night and the 07:00 run picks up the change. Zero deploys, zero re-running, zero risk that I forget to push a config change.

I think this is the most underrated pattern in the whole setup. **The skill's parameters live in Notion, not in code.** Working hours, skip list, customer-mapping rules — all of it. Not in Python, not in a YAML file in a repo I'd have to clone. If something feels wrong, I open the relevant page, make the edit, and the 07:00 run picks it up. No deploy, no restart, no second person involved.

The same page hosts two child databases:

**Skip List.** A two-column "meetings I never want briefs for" filter. Match Type is `Exact Title` or `Title Contains`; Active is a checkbox so I can disable a rule without deleting it. The skill walks this list before generating any brief. The current entries are the usual suspects — standups, brand-name daily syncs, "Lunch with [person]" — that are on the calendar but don't reward prep.

**Run Log.** A history of every 07:00 run. Status (`Success` / `Partial` / `Failed`), Duration, Meetings Found, Briefings Created, Skipped, Errors, plus a checkbox for `iMessage Sent` because the skill texts me a one-liner when the run finishes. The Run Log is what tells me the skill is healthy without me having to check anything. If I see two `Partial` rows in a row, I know to look.

## Customer / Partner Mapping Rules: the rulebook

The mapping rules deserve their own page because the rules-engine pattern shows up in a lot of places, and most people implement it badly the first time.

The rule of evaluation is simple and stated at the top of the page itself, so the next time I forget how it works I have to read no code:

1. **Email Domain rules** — match against every attendee's email domain, ignoring `@altra.cloud`.
2. **Title Keyword rules** — case-insensitive substring match on the meeting title.
3. **Internal fallback** — if every attendee email ends in `@altra.cloud`, set Customer / Partner to **Altra**.
4. **No match** — leave it blank.

First-match wins. Active=false rules are kept around for visibility, ignored at runtime.

The page also documents the gotchas, which I write into the page itself rather than the README of a repo nobody will read:

- The Pre-Call Briefings DB has select options that don't have rules yet (Advania, Thomas & Young, Plymouth City Council, …). If they start appearing on the calendar, add a rule.
- Four pre-loaded domain rules are inactive because the domain alone isn't authoritative for those partners. Activate when there's a matching select option.
- One select option is named `National  Grid` with two spaces. **Match it exactly.** I lost an afternoon to that one.

This last point is the kind of thing that doesn't belong in a comment in a Python file. It belongs on the page where the human is doing the work.

## What's missing from this, on purpose

A few things I deliberately don't have.

**No dashboards.** Notion dashboards age badly. The closest thing I have is the Today view in Calendar Events and the Default view in Pre-Call Briefings. Both are filters on the underlying DB, both update themselves.

**No customer database.** The pragmatic answer of "Customer/Partner is a select" beats the elegant answer of "Customer/Partner is a relation to a Customers DB." If I ever need rollups across customers, I'll build it. Today, I don't, and the cost of maintaining a half-populated customer DB is real.

**No tags-on-tags.** I have one categorical column per database, not three. The temptation in Notion is to make every property selectable and faceted; the cost is that you spend the rest of your life maintaining tag lists. The Categories on Meeting Notes are the only "tagging" in the whole setup, and they're a closed set of eight.

**No meeting-prep templates.** The Pre-Call Briefings page body is whatever the skill produced, plus whatever I added on top. I don't have a "Discovery Brief" template and a "QBR Brief" template and a "Pilot Brief" template. Templates fossilise — they don't get updated when the way I work changes, and they're a pain to fix when they're already attached to a hundred old briefings. The skill's prompt is the template, in effect, and the prompt lives in a file I can edit in five seconds.

## If you're copying this

A handful of decisions worth lifting directly:

1. **Calendar Events is the spine, not Meeting Notes.** Build it first. Make it dense. Sync every event, including the ones you don't care about. The downstream skills get filtering for free.
2. **Pick a non-obvious upsert key for recurring events.** `{master_uuid}_{ISO_local_date}` works. Don't key on iCal UID — keep it as a separate column for cross-system matching, but don't make it the row identity.
3. **Add a `Stale` state to anything humans edit.** The sync should never clobber a row a human touched. A `Sync State` column lets you keep the calendar fresh without losing your hand-edits.
4. **Skill parameters belong in Notion, not in code.** Working hours, skip lists, mapping rules. The cost of "the skill has to load a page on every run" is twenty milliseconds. The win is that you can edit it from your phone.
5. **Write a Run Log.** Cheapest possible observability, and the only thing that tells you whether the skill is dying quietly.
6. **Two columns per database do 90% of the work.** For Calendar Events it's `Has External Attendees` and `Apple Event ID`. For Pre-Call Briefings it's `Customer / Partner` and `Stage`. For Meeting Notes it's `Category` and `Action Items`. Get those right and the rest can be sloppy.

The whole setup took about two evenings to build, and most of that was figuring out the upsert key. The pre-call skill plugged into it without modification. The morning briefing plugged into it without modification. The thing that took longest, by far, was discovering which columns I actually needed once I'd been using it for a month — and that's the part you can't shortcut. Build the smallest version, live with it for a week, add a column every time you find yourself wishing one existed.

The skills run themselves now. The Notion looks after itself. I look after the meetings. Which is, finally, the right split of labour.
