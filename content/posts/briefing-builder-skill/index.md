---
title: "The Briefing Skill That Builds Itself Around You"
date: 2026-05-28T08:00:00Z
draft: false
description: "A Claude skill that interviews you about your tools and your job, then generates your own morning-briefing and call-prep skills. Now a download you can grab."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: ["claude", "automation", "productivity", "skills"]
categories: ["Projects", "Productivity"]
---

I ended [the pre-call brief post](/posts/pre-call-brief-skill/) with a section called "the setup": a four-step recipe for building the same thing yourself. A call-prep skill, a scheduled task, a Notion database, a way to get the brief in front of you at join time. Here's the shape, off you go.

That's the bit people wrote to me about. And the honest answer is that the recipe isn't enough, because every post I've written about this (that one, and [the morning briefing one](/posts/morning-briefing-skill/) before it) describes my setup. My Gmail. My Outlook for Mac. My Teams. A Notion database fed by a Mac app I built. "Here's the shape, go build it" really means "copy my skill and rewrite half of it for your stack." Which is a rubbish answer to give someone.

So I built the thing that should have existed in the first place. A skill that builds the skill.

## A skill that interviews you

The Briefing Builder is a meta-skill. You run it once, it asks you a short set of questions, and it writes two skills back. The questions are the obvious ones. What email you use. What chat you use. Where your calendar lives. What you actually do for a job, how many calls you sit through in a day, and what "important" means to you. Out the other end come a morning briefing and a call prep, both wired to your answers instead of mine.

## What it actually adapts

Three things change depending on what you tell it.

The first is where the briefing looks. Gmail or Outlook, Slack or Teams, Google Calendar or Notion or Cal.com. The skill it writes only reaches for the things you actually have, and skips the rest cleanly instead of leaving a dead step in the middle. No connectors at all? It drops back to web search and whatever you paste in. A thin briefing still beats no briefing.

The second is what counts as urgent, which isn't the same word for everyone. For an engineer it's incidents and blocked PRs. For someone in sales it's a hot deal going quiet, or a prospect who finally replied. For a founder it's investor mail and churn signals. The builder sorts the briefing along those lines, then lets your own answer to "what does high priority mean to you" override the lot.

The third is length, which comes down to how many meetings you survive in a day. Three calls and you get a full snapshot and a suggested agenda for each. Ten calls and that's just noise, so you get a tight checklist instead: open threads, attendee names, and not much else. About a third the size.

## Grab it

I've put it on the [downloads page](/downloads/briefing-builder/) as a `.skill` file. Download it, drop it in your skills directory, run it, answer the questions, and a few minutes later you've got your own pair of briefing skills. Set them up as scheduled tasks if you want the briefing sitting there before you've found the coffee.

It'll be your briefing, not a reskin of mine. Which was the point.
