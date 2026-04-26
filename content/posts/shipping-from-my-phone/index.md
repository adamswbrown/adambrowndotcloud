---
title: "Ten PRs Before Lunch, From My Phone"
date: 2026-04-26T10:00:00Z
draft: false
hero: images/posts/shipping-from-my-phone/hero.svg
description: "Two hours, ten merged PRs, no editor. Just a phone, Claude Code, and the prompting habits that turn the model from a coder into a release engineer."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A phone on a kitchen counter showing a GitHub PR list, coffee cup beside it"
tags: ["agentic-coding", "claude-code", "prompting", "side-projects", "productivity"]
categories: ["Projects", "Tech"]
summary: "Two hours, ten merged PRs, no editor. Just a phone, Claude Code, and the prompting habits that turn the model from a coder into a release engineer."
---

[Tour of the Bible](https://bible-tour.vercel.app) is a small web app that walks you through every book of the Bible in about ninety minutes. It's a side-project. I am not a frontend engineer. Every line of code in it has been written in conversational sessions with [Claude Code](https://claude.com/claude-code), and the `claude/...` branches scattered through the [git history](https://github.com/adamswbrown/bible-tour) are the receipts.

This morning I shipped ten pull requests from my phone, in about two hours, mostly from the kitchen between coffee refills. Per-verse ESV audio across two surfaces of the app. ESV added as a reading translation. A UX fix for the Strong's word-study mode. A README rewrite. A CHANGELOG backfilled to the project's first commit. I never opened an editor.

I should be honest up front: this morning went unusually cleanly. Some sessions get knotted up and I have to reset the conversation and start the bit again. Today nothing got knotted. But the *prompting* was the same prompting I always do, and it's the prompting (more than the model, more than the tool) that makes phone-based shipping reasonable instead of ridiculous. Six habits. None of them are about typing faster.

## What is Claude actually doing here?

Worth being explicit about who's doing what, because the honest answer changes how you prompt.

I'm doing product direction, scope decisions, and UX taste. I'm the one who knows what's worth building and the one who eventually says "ship it". Claude is doing research, implementation, the mechanics of git and PRs and CI, and (when I let it) telling me what I'd be giving up before I commit to anything. I make the calls. Claude does the work and pushes back when I'm wrong. That's the whole contract, and the rest of this post falls out of it.

Most of what I see go badly with these tools is people getting that boundary wrong in either direction: micromanaging implementation, or handing over the product decisions. Both feel productive in the moment. Neither ends well.

## 1. Talk first, code last

The first prompt I sent this morning was, in full, six words.

> *"Research audio bible api options."*

No spec. No solution. No file paths. Just a direction.

Six words bought me a survey of every realistic option in the space. Bible Brain. API.Bible. The YouVersion developer API, which, as it turns out, has no audio endpoint at all (mild surprise, that one). The eBible.org public-domain WEB recordings. The [Zaxser/verse-timings](https://github.com/Zaxser/verse-timings) forced-alignment dataset. Crossway's ESV API. Each came back with licensing terms, rate limits, and a verdict.

If I'd opened with *"Add audio playback using the YouVersion API"* I'd have spent half an hour discovering that the endpoint doesn't exist, probably with a half-built proxy route already on the branch. Open prompts produce better research than narrow ones, because they give the model permission to disagree with your premise before it touches any code.

The cheapest line of code is the one you decided not to write.

## 2. Devil's advocate as a service

This is the prompt I get the most out of, and the wording matters, so I'll give it to you verbatim.

> *"Play devil's advocate around the idea of full translation support for the audio. If that's going to add a level of complexity I can't really support, convince me of my options."*

I had a goal already. Per-verse audio playback that matched whichever translation the user had picked: NIV, NIrV, NIVUK, KJV, WEB, ASV. It felt right. It mirrored the existing text experience. I half-believed in it. Half-believing is the dangerous bit, because half-belief is enough to start building.

Five points came back, and the goal collapsed in the time it took to read them.

1. NIV/NIrV/NIVUK can't be embedded legally. Biblica doesn't licence audio for third-party players at any free tier. Translation parity was already impossible. Anything I built was going to be a hybrid the moment it touched the licensed translations.
2. Listeners don't pick translations the way readers do. Translation choice is a *reading* decision. When you press play you mostly want a clear voice reading the words.
3. Audio is supplemental in this app. The product is a 90-minute reading checklist; audio is a convenience layer on top.
4. Each translation is recurring engineering work for marginal value. Sourcing, licensing, hosting, fixing it when sources move. Per-translation cost, per-translation maintenance, per-translation nothing-much.
5. WEB and KJV cover most of what a casual listener actually wants.

That's days of integration work I won't do, plus a version of the feature that actually ships.

The trick isn't asking the model to validate you. It's asking it to argue against you. *"Convince me of my options"* forces an opinionated counter-proposal instead of a polite pros-and-cons list. I keep this one in my head for any feature larger than an afternoon's work, because it catches the kind of premise mistake that no amount of careful implementation can fix.

## 3. Make "easy" a first-class requirement

I asked for the *easiest* option three times this morning, not the best. "Easy" isn't a word engineers love. It feels like you're asking for the cheap version of the thing. But if you don't say it out loud, you don't get it.

Ask for the *best* path and you get a menu. Ask for the *easiest* and you get a recommendation. The constraint forces an opinion.

Here's what "easiest" ruled out for me, in one move.

- Forced alignment of chapter MP3s to extract per-verse clips. (Possible. A week of work.)
- Pre-slicing 234 verse-clip MP3s and bundling them with the app. (Possible. A day of work plus storage.)
- Running multiple audio sources behind a translation-aware switch. (Possible. Hybrid UX.)
- Browser SpeechSynthesis as a synthetic-voice fallback. (Possible. Sounds bad on Android.)

The shortlist that survived was Crossway's ESV `/v3/passage/audio/?q=ref` endpoint. One HTTP call returns a 302 to an MP3. I forward the 302 to the browser, the `<audio>` tag follows it, Crossway's CDN serves the bytes, edge cache for seven days, done. Two hours of work.

If "easy" hadn't been a stated requirement, I'd have ended up with something more clever and less shipped.

## 4. Trust, but with named tradeoffs

When Claude proposes a direction, my answer to *"want me to ship?"* is usually yes, but only because the proposal explicitly lists what I'd be giving up.

Boiled down, the actual structure of a Claude proposal from this morning looked like this.

> Pick the ESV API. Two-hour integration. Real human narration. Pattern matches your existing `/api/verse` proxy.
>
> Tradeoffs:
> 1. Audio is always ESV, regardless of selected reading translation.
> 2. Free for non-commercial only. Crossway approval required if you ever monetise.
> 3. Adds a Crossway API key to env vars (the existing YouVersion key is already in there).

I trust the implementation because the tradeoffs are named in advance. If they're hidden, I push back and ask for them.

It's also how I catch over-engineering, which is honestly the failure mode I see most often with this stuff. If a proposal *doesn't* list any tradeoffs, the model has usually reached for a heavier solution than the problem deserves. Ask for an email; it proposes a queue. Ask for a form; it suggests an architecture. *"What does this give up?"* is a good follow-up when nothing has been volunteered.

## 5. Mobile-first orchestration

I was on my phone all morning. No editor. No localhost. No `npm run dev`. I could read GitHub diffs in a tiny font and that was about it. So the loop had to look different from how most people use Claude.

The strategy was continuous deployment plus aggressive delegation. Every PR Claude opened got merged to `main` immediately. Vercel rebuilt production within a minute. I tested on the live site, on my phone, after each merge. Real users were potentially hitting features I'd shipped sixty seconds earlier. That feels reckless, and there's a small wince every time. But the alternative on a phone is testing nothing at all, and I'd rather a real user catch a bug in a free side-project than ship a wall of unverified code at the end of the morning.

This put Claude in a role most people don't ask it to play, which is release engineer. Branch from latest `main`. Commit with a sensible message. Push. Open a draft PR. Watch CI. Merge once green. Unsubscribe from the PR webhook. All autonomous. I'd authorise *"push to prod"* once and Claude would handle the mechanics every time afterwards.

Claude Code's `subscribe_pr_activity` was carrying a lot of weight here. It let Claude react to every CI signal and review comment as it landed, without me babysitting GitHub from my phone. When Vercel posted a preview-ready comment, Claude triaged it ("informational only, no action") and moved on. When CI eventually goes red on something, Claude will investigate and propose a fix without me asking.

Which means Claude wasn't just my pair-programmer in this setup. It was my CI dashboard, my reviewer, my deploy bot. That's the difference between AI helping you write code and AI running the loop while you make decisions, and the second one is the thing that scales to phone-only.

## 6. Documentation as a deliverable

I treat README and CHANGELOG updates as part of the feature, not a follow-up. Same-day docs are the only ones that ever happen on a side-project; everyone who has ever said "I'll come back and write that up later" is lying to themselves, and I include myself in that.

This is also where AI assistants are unfairly good. They remember exactly what they just built. They have all the context. They will write the README change *better* than you would, because they're working from the implementation rather than from memory.

Late in the session I asked Claude to backfill the CHANGELOG to project inception. That's hours of code archaeology. Walking the git log, consolidating intermediate work commits, attributing changes to the right PRs, classifying everything as Added/Changed/Removed/Fixed. One prompt, one PR, done. I'd never have done it by hand.

If your assistant is doing the implementation but not the docs, you're leaving a lot of value on the table.

## The session, end to end

Six habits, applied to one morning. Here's the arc.

At nine, I asked it to research audio Bible API options. Fifteen minutes later I had a survey of seven options with verdicts. By twenty past, the devil's-advocate prompt had killed translation parity, and the goal had shrunk to "one good audio source for every reference". By half past, the answer to "easiest path" was the ESV API.

At twenty-five to ten Claude scaffolded `/api/verse-audio` as a near-copy of the existing `/api/verse` proxy. Inline `<audio>` landed in the verse panel. Crossway citation rendered alongside. Push to prod, and I tested on my phone. Audio worked.

Ten o'clock was the realisation that the same Crossway API key powers ESV *text* at `/passage/text/`. A half-hour upgrade later, ESV was a reading translation. By half ten the UX was tidied: an "ESV Audio" pill so users could see which translation the audio uses, an Originals-mode auto-switch to KJV (Strong's tagging is KJV-only, which had been making the toggle look broken on ESV), and the inline `[N]` verse markers stripped from the ESV text because the panel header already names the range.

Eleven, the same pattern got extended to the Eagle Method book pages, with ESV text and a *toggleable* audio player. Toggle defaults to off, because the page shows five-plus verse cards in a grid and always-on audio would be visual noise.

By half eleven the README was updated and the CHANGELOG had been backfilled to project inception. By ten to twelve, ten PRs were merged: [#16](https://github.com/adamswbrown/bible-tour/pull/16) through [#25](https://github.com/adamswbrown/bible-tour/pull/25). Two new API routes, one new translation, one new toggle, zero new dependencies, two hours.

## What I take from this

Translation parity was the ambitious goal; one translation that works everywhere was the shipped product. That isn't a compromise, it's the right answer, and that's the lesson I keep relearning: constraints that ship beat goals that don't.

Free upgrades compound, and you should look for them. Once the Crossway key was in production for audio, ESV text was a half-hour add. The same will be true wherever an integration's surface area is small.

Toggles are a real design tool, not a hedge. The Eagle audio toggle isn't *"we couldn't decide"*; it's the right UX for a dense grid where always-on audio would clutter the page.

Open prompts produce better research than narrow ones. *"Research X"* gives a survey. *"Implement X"* jumps straight to code and skips the part where you decide whether X is even the right thing to build. And tell the model what kind of answer you want, while you're at it. *"Easiest."* *"Most architecturally consistent."* *"Convince me of my options."* *"Play devil's advocate."* That's how you get opinionated output instead of waffle.

Treat the model like a senior collaborator, not a junior coder. Hand it scope decisions and licence to push back. It will, if you let it. Most users don't.

Ship the docs in the same session as the code, because the model has the context and you have the momentum, and both fade fast.

And let the model run the release loop. PRs, CI signals, merges, Vercel deploys; none of that needs to come back to you. Subscribe to the webhook activity, set the merge policy, and stay in the strategic loop.

The thing I've come to believe, after a few months of building this way, is that building with AI doesn't really mean *automating the act of coding*. Anyone can prompt for code. It means automating the engineering loop *around* the coding (research, scoping, branching, CI, deploy, docs) so the only thing left for you to do is product judgement.

That's also why phone-shipping works at all. You can't write code on a phone, but you can absolutely make decisions on a phone, and on a morning like this one, decisions are the only thing the work actually needs from me.

I made decisions for two hours this morning. Claude turned each one into a shipped PR. That ratio is the win, not the line count.

---

*[Tour of the Bible](https://bible-tour.vercel.app) is a fan-built companion to Matt Whitman's [Lightning-Fast Field Guide to the Bible](https://www.thetmbh.com/tourofthebible). Code at [github.com/adamswbrown/bible-tour](https://github.com/adamswbrown/bible-tour). Built by [Adam Brown](https://askadam.cloud/) and Claude.*
