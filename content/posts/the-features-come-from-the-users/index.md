---
title: "The features come from the users"
date: 2026-06-01T08:00:00Z
draft: false
description: "A user emailed me three small suggestions for Tour of the Bible. All three shipped this morning. None of them would have happened if he hadn't written."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: ["bible", "react-native", "expo", "mobile", "side-project", "claude-code"]
categories: ["Projects", "Faith"]
---

A guy called David emailed me last week about Tour of the Bible. He'd been working through the 66-book reading plan for a couple of weeks and had three suggestions. All small. All the kind of thing you only notice when you're actually living with the app.

I shipped them this morning. They're in TestFlight as 1.0.2 and on the [web](https://bible-tour.vercel.app) already. The thing I want to write down is that none of them would have happened if David hadn't reached out.

## What David asked for

**Show me how far I've come.** Tour has a progress bar that says "23 of 66 books, 35%" but the bar doesn't celebrate anything. David wanted markers. Something that says "you're a quarter of the way through" when you cross 17 books. Something that doesn't just count down to 100% and then ghost you when you get there.

So now there are four milestones. Taking Flight at 25%. Halfway There at 50%. Almost Home at 75%. Tour Complete at 100%. Tick a book that pushes you over one of them and a celebration pops. A small disc shelf under the progress card shows all four; the ones you've earned glow gold, the ones still ahead sit muted.

Anyone who was already past a threshold when they updated didn't get a surprise pop-up. They opened the app and the shelf was already filled in. Silent backfill. Felt right.

**Let me page through a book's verses without leaving the reader.** Some books have two or three key passages in the plan. Genesis has 12:2-3 and 50:20. Exodus has 3:7-8 and 20:1-17. Before David emailed me, you'd read one, tap close, find the next on the list, tap it again. He wanted Prev and Next in the reader itself.

So now there's a small nav row at the bottom of the verse panel: "‹ Previous · 1 / 2 · Next ›". Tap and the reader re-renders without bouncing you out to the checklist.

**Tell me how to dismiss this thing on the phone.** The web verse panel has an X. On mobile, the panel slides up from the bottom. iOS users tend to swipe down to close it, but nothing told them that was the gesture. David figured it out eventually, but he was guessing.

So now there's a grabber handle at the top of the panel and a one-line hint underneath: "Swipe down to go back." Two centimetres of pixels, and the kind of thing you can't unsee once someone points it out.

## The bigger point

If David hadn't emailed, none of this would exist. I'd have shipped the mobile app, taken the win, moved on. The features that come from someone actually using the app are smaller and more obvious in hindsight than anything I'd come up with on my own. And they make the thing better.

I'm going to keep being deliberate about asking. There's a feedback button in the app for a reason — and a [bibletour@askadam.cloud](mailto:bibletour@askadam.cloud?subject=%5BBible%20Tour%5D%20Feedback) email behind it.

## While I'm here: Memory

A friend from my church men's group was lamenting the other week that nobody does memory verses anymore. Not properly. We all underline them in passing and then forget the words by lunchtime. The discipline of actually locking a verse into your head — saying it back when prompted, knowing you've got it — has quietly disappeared.

So I built [Memory](https://bible-tour.vercel.app/memory). It's a scheduler-free verse memorisation surface: save a verse, fade words in or out at your own pace, work it until it sticks. No nightly review queue, no "you're behind", no streak you can break. You go when you want to and the words go away gradually.

It pairs well with the Tour. You're reading through 66 books with a curated key verse per book; once one of them lands, you can drop it straight into Memory and keep it.

It's on the web. It's not on the phone. Yet.

## Which one's next?

If you're using Tour of the Bible on iOS, two open questions:

1. **Do you want [Memory](https://bible-tour.vercel.app/memory) on the phone?** Same surface that's on the web today, in your pocket.
2. **Do you want [Eagle](https://bible-tour.vercel.app/eagle) on the phone?** Eagle is the other thing the web app does — pick a verse and it walks you through three stages: Survey (who wrote the book, when, why), Map (where the verse sits in the chapter), and Current (what's happening in the chapters around it). It's what turns "read the verse" into "understand the verse."

I can only do one of these next. Hit the feedback button in the app, email [bibletour@askadam.cloud](mailto:bibletour@askadam.cloud?subject=%5BBible%20Tour%5D%20Memory%20or%20Eagle), or reply to this post and tell me which.
