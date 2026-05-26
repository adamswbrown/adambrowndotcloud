---
title: "The Pre-Call Brief That Writes Itself"
date: 2026-05-27T08:00:00Z
draft: false
description: "A Claude skill that writes a briefing for every meeting on my calendar, every morning at 07:00, and Meeting Reminder slots it in front of me the moment I join the call."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: ["claude", "automation", "productivity", "notion", "skills", "sales"]
categories: ["Projects", "Productivity"]
---

I take a lot of calls. Partner syncs, customer technical reviews, internal architecture chats, the occasional demo. On a bad week it's eight a day. On a good week it's also eight a day, just with more interesting topics.

Eight calls a day is more than my brain wants to hold. I would join a customer call having genuinely forgotten what we discussed three weeks ago. I would walk into a partner sync and spend the first ten minutes catching up to context I should have had on the way in. Sometimes I'd realise mid-call that I'd committed to send something last time and never had.

This is not a moral failing. It is a working-memory failing.

So I built a call-prep skill. Then I scheduled it for 07:00 every morning and let it write a briefing page per meeting into a Notion database called `Pre-Call Briefings`. By the time I'm at my desk, every call I have today already has a brief written for it. I do not have to remember to run anything. The skill does not need me.

## How it actually works

The skill runs as a scheduled task at 07:00. It walks every meeting in my Notion `Calendar Events` database for the next 24 hours and builds a brief per row.

For each meeting, it pulls from the CRM (account history, open opportunities), email (recent threads, anything I committed to), Slack (internal context on the account), past meeting notes already in Notion, the calendar invite itself, and a web search for recent news plus LinkedIn profiles of attendees I haven't met.

The skill writes a Notion page per meeting, links it back to the `Calendar Events` row via a relation, and goes back to sleep.

If I have no connectors set up, it falls back to standalone mode: I tell it the company, the meeting type, and any context I have, and it does the web research itself. The connectors make it sharper. They are not required.

## How the brief gets in front of me

Writing the brief at 7am is the easy half. Getting it in front of me at 09:29, sixty seconds before the 09:30 call, is the harder half.

That's what [Meeting Reminder](/posts/building-meeting-reminder/) does. It's a Mac menu bar app I built for the meeting-side problem: knowing what's about to happen, getting into the call on time, and getting context the moment I'm in the room. When I join, Meeting Reminder opens a context panel that reads the linked `Pre-Call Briefings` row out of Notion and shows it next to the meeting. Attendees, the cleaned-up calendar notes (with the Teams "Join the meeting now / Meeting ID / Passcode" boilerplate stripped, which is about 400 characters of pure noise per invite), and the AI-generated brief on top.

The interesting design decision was when to fetch the brief. The obvious answer is when I click Join. But fetching from Notion takes a second or two, and I'm already trying to get into a call. So it fires from `ContextPanelView.onAppear` after the join has happened. The panel renders with a skeleton, the brief slots in when it's ready. The join click stays instant.

The result is that I never have to remember the brief exists. I join the call, the panel opens, the brief is there.

## What the brief looks like

Here's a redacted example of one the skill wrote for me last week. It was for a 30-minute technical sync with a partner running a migration assessment on behalf of an end customer.

```markdown
# Call Prep: Northwind Partners — migration assessment review

Meeting: Technical sync, Thursday 14:00 BST
Attendees: Priya Shah (Solutions Architect, Northwind),
           James Okafor (Pre-Sales, Northwind)
Linked: Calendar Events row, Pre-Call Briefing page

## Snapshot

| Field        | Value                                                |
|--------------|------------------------------------------------------|
| Account      | Northwind Partners, Tier 2 partner since 2024        |
| Engagement   | Active: Contoso Ltd assessment, 1,400 VMs in scope   |
| Last contact | 14 days ago, email thread re: DMC appliance sizing   |
| Open threads | 3 (see below)                                        |

## Open threads

1. DMC sizing for Contoso. Priya asked on 12 May whether a single DMC
   would handle the load or if we needed two. I replied with the 800-VM
   rule of thumb and said I'd confirm against the latest sizing guide.
   I have not sent the confirmation.
2. Automap loader run. James reported the loader exited with
   `OS error 17` on their first run. I asked for the log workspace ID,
   they sent it on 18 May. I have not looked at the logs yet.
3. License request 40219. Submitted last week, still in review on the
   Assessment Desk. Priya will probably ask about it.

## Who you're meeting

### Priya Shah, Solutions Architect
- Has run two prior Dr Migrate assessments with us, both completed cleanly.
- Technical, pragmatic. Likes specifics. Does not enjoy being told things
  are "in progress" without a date.
- Last time you spoke, she was about to take three weeks off. She's back today.

### James Okafor, Pre-Sales
- Newer to the partnership, this is his second call.
- Less technical than Priya, owns the commercial side of the Contoso deal.

## Suggested agenda

1. DMC sizing. Confirm one appliance is fine, share the sizing guide page.
2. Automap loader error. Pull the logs before the call, walk Priya through
   what the error meant and what to retry.
3. License request 40219. Flag that you've nudged the Assessment Desk and
   expect a response by Friday.
4. Anything else from their side.

## Pre-call to-dos

- [ ] Pull DMC sizing guide page link (altra docs)
- [ ] Run KQL on workspace `[id]` for the AutomapLoader run from 18 May
- [ ] Check Assessment Desk status on 40219
```

The to-do list at the bottom is the part I lean on most. Three items, all of which I'd otherwise forget, all of which the customer is going to ask about. Five minutes of work before the call. The call itself then goes smoothly instead of devolving into "let me check on that and get back to you."

## What it changed

I stopped wasting the openings of calls. I no longer ask "where did we leave off?" because I already know. I open with "I pulled the logs from your 18 May run, here's what `OS error 17` was about" and we're into the actual conversation a minute in.

I also stopped dropping commitments. Before this skill, I'd say "I'll send you the sizing guide" and then forget for two weeks until the customer chased. Now the brief surfaces every open commitment from the previous call as a pre-call to-do. I close them out in the five minutes before the meeting. The customer never has to chase me. That alone is worth the build.

The thing I care about most, though, is that my Notion data is now self-cleaning. Every morning I see the briefs the skill produced. Gaps in the brief are gaps in my data. Wrong attendee role? Update the CRM. No prior meeting notes for an account I know I've spoken to? I clearly didn't log the last call. The brief is a mirror. It tells me where I've been sloppy, and I get a daily prompt to fix it.

## Where it falls down

The skill is only as good as the context I give it. If I haven't logged the last three conversations with an account, the brief doesn't know they happened. On the days I ignore the "your Notion is sloppy" signal, the brief is correspondingly less useful.

It also cannot do the call for me. The brief tells me what to ask and what to follow up on. It does not make me listen well, or take good notes during the call, or actually do the to-dos. That is still my job. What the skill removes is the excuse of "I didn't have time to prep." It does not remove the work.

## The setup

If you want to build the same thing, the shape is:

1. A call-prep skill that takes a meeting and produces a brief, using whatever connectors you have.
2. A scheduled task that runs the skill against tomorrow's meetings every morning at 07:00.
3. A Notion (or equivalent) database to hold the briefs, linked back to your calendar.
4. A way to surface the brief at join time. Meeting Reminder does this for me on a Mac. The cheaper version is a Notion view filtered to today's meetings, open in a tab.

Once it's running, you forget about it. Which is the point.
