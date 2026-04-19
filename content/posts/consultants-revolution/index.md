---
title: "Agentic Coding Is the Consultant's Revolution"
date: 2026-04-19T16:00:00Z
draft: false
hero: images/posts/consultants-revolution/hero.svg
description: "I'm a principal consultant, not a developer. I still ship software. Here's what agentic coding looks like when the person driving it cares more about outcomes than about the code."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A Sunday dining table with a laptop, coffee, and a half-eaten breakfast"
tags: ["agentic-coding", "claude-code", "consulting", "side-projects", "productivity"]
categories: ["Projects", "Tech"]
summary: "I'm a principal consultant, not a developer. I still ship software. Here's what agentic coding looks like when the person driving it cares more about outcomes than about the code."
---

I'm a principal consultant at a software vendor — an ISV in the Azure space. My job is explaining things for a living. Technical people, non-technical people, buyers, operators, engineers who are about to have a bad week. If you want a fancier description: I'm a babelfish. I translate technical into non-technical and back again, and I do it about fifty times a day.

I am not a developer. I have never been a developer. I don't care very much about the code.

And yet over the last few months I've shipped five public projects, three of which are in daily use by people who aren't me. All of them exist because of agentic coding — Claude Code in particular — and the story of how they got built is probably the most interesting thing that's happened to software in the last twenty years. I don't say that lightly.

## Sunday, at the dining room table

Tour of the Bible — a reading companion for a little book by Matt Whitman — was built on a Sunday. I was at the dining room table, making breakfast, drinking coffee, half-reading something else. I kicked it off, went to church, came back, kept chores moving, and in between all of that I was sending prompts from my phone using iOS dictation. Voice notes. Questions. *"What's the simplest way to cache the verse lookups?"* *"Would you use localStorage or IndexedDB?"* *"Pick whichever matches how the rest of the app is written."*

The moment that genuinely shocked me was the first Vercel push. I'd already hooked Vercel up to something else. Claude either suggested we push or agreed when I did — I can't remember — and the first deploy just worked. I opened the URL. I clicked things. The things I clicked did the things I'd asked for. No going off-piste, no half-finished pages, no "oh wait this bit's broken." It was an articulation of the solution to the problem I'd described, shipped.

That is not how software used to feel.

## The projects that wouldn't exist

I have two projects that wouldn't exist without agentic coding. Not "would have taken longer." Not "would have been worse." *Wouldn't exist.*

The first is **[ProPresenter Lyric Export](/posts/propresenter-lyrics-export/)**. It pulls lyrics out of ProPresenter 7 — a piece of church presentation software — and turns them into PowerPoint, JSON, or text. It solves one specific problem for a small group of people doing Sunday-morning tech at churches. Commercially, it's a terrible idea. Nobody was ever going to build this. But point an agent at the ProPresenter SDK, point it at the API specs, have it build and test integrations iteratively, and you can ship a working tool in an afternoon. When something breaks — and occasionally something does — you paste the error back into the agent, it analyses, and more often than not it's fixed before you've finished your next sip of coffee.

The second is **[Meeting Reminder](/posts/building-meeting-reminder/)**. I have ADHD. I suffer from time blindness — the meeting-in-15-minutes feeling and the meeting-started-four-minutes-ago feeling are indistinguishable to me until I see a Slack DM asking where I am. I was already using Setapp for a bundle of apps that included one that solved this, but I was trying to trim subscriptions. So I built a replacement. It's now starting to replace parts of that bundle, and it's tuned specifically to how *my* brain misses meetings — progressive alerts, a persistent countdown in the menu bar, a "wrap up" nudge that reframes the next ten minutes.

Neither of these would have got built if I'd had to write the code by hand. Not because the code is especially hard — it isn't — but because the *cost* of building them would have outweighed the *benefit* by a factor of about fifty. Agentic coding collapses that ratio.

## The honest take on failure

I've been using this toolset every day for months and I have no catastrophic-failure story to tell you. Nothing has crapped the bed. Nothing I've deployed has been so wrong it embarrassed me. The worst I can offer is *"sometimes it over-engineers."* You ask for a form. It suggests an architecture. You push back, it simplifies. You ask for an email notification; it proposes a queue. You say "no, just email"; it emails.

Occasionally it gets tied in knots — loses the thread of what the actual problem is, chases a misunderstood detail. You notice this because the answers stop feeling like they're solving your problem and start feeling like they're solving a different, more interesting one. You reset the conversation, restate the goal, and you're back on track.

This doesn't match what I see on LinkedIn, where every third post is someone declaring that agentic coding is a disaster and the junior engineers of tomorrow will all be typing `rm -rf ~` into production. That hasn't been my experience. I'm not saying it can't happen. I'm saying it hasn't happened to me, and I've been *trying*.

## The workflow, actually

A normal week looks like this:

- Desk work with agent swarms running in the background on longer tasks while I do other things.
- Dispatch (the hosted runner) for tasks I kick off from my phone or laptop and come back to.
- Claude Code on my phone, genuinely used — voice notes, iOS dictation, standing in a queue somewhere describing what I want next.
- A lot of "tell me the outcome, help me understand the journey."

I care about the outcome. I care about whether it solves the problem. I care about whether the thing I shipped actually makes someone's life better. I care considerably less about whether the code follows the latest pattern, whether the architecture would win a code review at a FAANG, or whether a purist would weep at the line count. If the tool works — if it does the job — *it works*.

## The provocation

Here's the thing a lot of engineers don't want to hear: software doesn't need to make money to be worth building. And it doesn't need to be written perfectly to be worth shipping. It needs to *work*. It needs to solve the problem it was built for.

For twenty-odd years, the economics of software meant that "worth building" and "worth making money from" were roughly the same sentence. You couldn't justify the hours otherwise. Agentic coding breaks that. I can spend a Sunday building a thing that will only ever be used by twenty people in my church, and the math still adds up, because the Sunday cost me nothing I wouldn't have spent anyway. I was going to drink coffee. I was going to do chores. The building happened in the gaps.

This is the consultant's revolution, not the engineer's. Engineers were already productive. The people who gain the most from agentic coding are the ones who *saw problems and couldn't build solutions* — the consultants, the operators, the analysts, the teachers, the church tech teams, the people who knew exactly what needed to exist and couldn't get it built because the economics never worked. Those people can now build. And they will.

## Whether I "understand" the code

Someone always asks this. *"But do you understand all 2,000 lines of Swift/TypeScript/HTML that it wrote for you?"* Not line by line. I understand the problem. I understand the scope of the solution. I understand the shape of what it built and where each bit lives. I can navigate the codebase, read any specific file, and reason about what's happening. That is the understanding that matters.

Asking me to hand-verify every line is like asking a general contractor to personally understand the metallurgy of every nail. The skill is knowing what you're building, why, and whether what got built matches the intent. The skill has shifted from *writing* to *specifying and judging*. That's not a smaller skill. It might be a bigger one.

## The summary, for the reader in a hurry

- I'm a consultant, not a developer.
- I have shipped more working software this year than in the previous ten.
- It works. It solves real problems. Real people use it.
- It was mostly built on Sundays, in queues, and between meetings.
- No, I don't understand every line. Yes, I understand what I built.
- If you're not a developer and you've been waiting for the moment when the barriers dropped far enough that you could finally build the thing you've had in your head for years — the moment is now.

See a problem. Solve a problem. Build the tool to help yourself.

The rest will follow.
