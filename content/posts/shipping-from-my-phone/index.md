---
title: "Ten PRs Before Lunch, From My Phone: The Prompting That Made It Reasonable"
date: 2026-04-26T10:00:00Z
draft: false
hero: images/posts/shipping-from-my-phone/hero.svg
description: "Two hours, ten merged PRs, no editor — just a phone, Claude Code, and six prompting patterns that turn the model from a coder into a release engineer."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A phone on a kitchen counter showing a GitHub PR list, coffee cup beside it"
tags: ["agentic-coding", "claude-code", "prompting", "side-projects", "productivity"]
categories: ["Projects", "Tech"]
summary: "Two hours, ten merged PRs, no editor — just a phone, Claude Code, and six prompting patterns that turn the model from a coder into a release engineer."
---

[Tour of the Bible](https://bible-tour.vercel.app) is a small web app that walks you through every book of the Bible in about ninety minutes. It's a side-project. I am not a frontend engineer. Every line of code in it has been written in conversational sessions with [Claude Code](https://claude.com/claude-code) — the `claude/...` branch prefixes scattered through the [git history](https://github.com/adamswbrown/bible-tour) are the receipts.

This morning I shipped ten pull requests from my phone, in about two hours. Per-verse ESV audio across two surfaces of the app. ESV added as a reading translation. A UX fix for the Strong's word-study mode. README updates. A CHANGELOG backfilled to the project's first commit. I never opened an editor.

This post isn't really about what I shipped. It's about the *prompting* that made shipping it from a phone reasonable instead of ridiculous. Six patterns. They're worth more than any specific model or tool.

## The setup: what is Claude actually doing?

It's worth being explicit about the division of labour here, because the honest answer changes how you prompt.

| My job | Claude's job |
|---|---|
| Product direction | Research |
| Scope decisions | Implementation |
| UX taste | Git mechanics, PR + CI orchestration |
| Knowing what's worth building | Knowing how to build it |
| Saying *"ship it"* | Saying *"here's what you'd give up"* |

I make decisions; Claude implements them and pushes back when I'm wrong. That's the contract. Every pattern below is downstream of it.

## Pattern 1 — Talk first, code last

The first prompt I sent this morning was, in full, six words:

> *"Research audio bible api options."*

No spec. No solution. No file paths. Just a direction.

Six words bought me a survey of every realistic option in the space: Bible Brain, API.Bible, the YouVersion developer API (which, as it turns out, has no audio endpoint at all — surprise), the eBible.org public-domain WEB recordings, the [Zaxser/verse-timings](https://github.com/Zaxser/verse-timings) forced-alignment data set, the Crossway ESV API. Each one came back with licensing terms, rate limits, and a verdict.

If I'd opened with *"Add audio playback using the YouVersion API"* I'd have wasted half an hour discovering that endpoint doesn't exist. Open prompts produce better research than narrow ones, because they give the model permission to disagree with your premise *before* it touches any code.

The cheapest line of code is the one you decided not to write.

## Pattern 2 — Devil's advocate as a service

This is the highest-leverage prompt I know. I'll give you the wording verbatim, because it matters:

> *"Play devil's advocate around the idea of full translation support for the audio. If that's going to add a level of complexity I can't really support, convince me of my options."*

I had a goal already: per-verse audio playback that matched whichever translation the user had picked — NIV, NIrV, NIVUK, KJV, WEB, ASV. It felt right. It mirrored the existing text experience. I half-believed in it.

Five points came back, and the goal collapsed in the time it took to read them:

1. **NIV/NIrV/NIVUK can't be embedded legally.** Biblica doesn't licence audio for third-party players at any free tier. Translation parity was already impossible — anything I built was going to be a hybrid the moment it touched the licensed translations.
2. **Listeners don't pick translations the way readers do.** Translation choice is a *reading* decision. When you press play you mostly want a clear voice reading the words.
3. **Audio is supplemental in this app, not the headline.** The product is a 90-minute reading checklist. Audio is a convenience layer on top.
4. **Each translation is recurring engineering for marginal value.** Sourcing, licensing, hosting, maintaining when sources move — per-translation cost, marginal user value.
5. **WEB and KJV cover ~90% of what a casual listener actually wants.**

Days of integration work I won't do, plus a version of the feature that actually ships.

The trick isn't asking the model to validate you. It's asking it to argue *against* you. *"Convince me of my options"* forces an opinionated counter-proposal instead of a polite pros-and-cons list. I now keep this prompt in my head for any feature larger than an afternoon's work. It catches premise-level mistakes that no amount of careful implementation can fix.

## Pattern 3 — Make "easy" a first-class requirement

I asked for the **easiest** option three times this morning, not the best. That word is doing a lot of work.

When you ask for the *best* path you get a menu. When you ask for the *easiest* you get a recommendation. The constraint forces an opinion.

Here's what "easiest" ruled out for me, in one move:

- Forced alignment of chapter MP3s to extract per-verse clips. (Possible. A week of work.)
- Pre-slicing 234 verse-clip MP3s and bundling them with the app. (Possible. A day of work plus storage.)
- Running multiple audio sources behind a translation-aware switch. (Possible. Hybrid UX.)
- Using browser SpeechSynthesis as a synthetic-voice fallback. (Possible. Sounds bad on Android.)

The shortlist that survived: Crossway's ESV `/v3/passage/audio/?q=ref` endpoint. One HTTP call returns a 302 to an MP3. I forward that 302 to the browser, the `<audio>` tag follows it, Crossway's CDN serves the bytes, edge cache for seven days, done. Two hours of work.

If "easy" hadn't been a first-class requirement, I'd have ended up with something more clever and less shipped.

## Pattern 4 — Trust, but with named tradeoffs

When Claude proposes a direction, the answer to *"want me to ship?"* is *"yes"* — but only because the proposal explicitly lists what I'd be giving up.

Boiled down, the actual structure of a Claude proposal from this morning looked like this:

> **Pick the ESV API.** Two-hour integration. Real human narration. Pattern matches your existing `/api/verse` proxy.
>
> **Tradeoffs:**
> – Audio is *always ESV*, regardless of selected reading translation.
> – Free for non-commercial only — needs Crossway approval if you ever monetise.
> – Adds a Crossway API key to env vars (existing YouVersion key is already in there).

I trust the implementation because the tradeoffs are named in advance. If they're hidden, I push back and ask for them.

This is also how I catch over-engineering. If a proposal *doesn't* list any tradeoffs, that's usually a sign the model has reached for a heavier solution than the problem deserves. *"What does this give up?"* is a useful follow-up when none have been volunteered.

## Pattern 5 — Mobile-first orchestration

I was on my phone all morning. No editor. No localhost. No `npm run dev`. I could read GitHub diffs in a tiny font and that was about it. So the loop had to look different from how most people use Claude.

The strategy was continuous deployment plus aggressive delegation. Every PR Claude opened got merged to `main` immediately. Vercel rebuilt production within a minute. I tested on the live site, on my phone, after each merge. Real users were potentially hitting features I'd shipped sixty seconds earlier. That feels reckless until you remember the alternative is testing nothing at all.

This shifted Claude into a role most people don't ask it to play — **release engineer**. Branch from latest `main`. Commit with a sensible message. Push. Open a draft PR. Watch CI. Merge once green. Unsubscribe from the PR webhook. All autonomous. I'd authorise *"push to prod"* once and Claude would handle the mechanics every time afterwards.

Claude Code's `subscribe_pr_activity` was load-bearing here. It let Claude react to every CI signal and review comment as it landed, without me babysitting GitHub. When Vercel posted a preview-ready comment, Claude triaged it ("informational only, no action") and moved on. When CI eventually goes red on something, Claude will investigate and propose a fix without me asking.

The implication: Claude isn't just my pair-programmer in this setup. It's my CI dashboard, my code reviewer, and my deploy bot. That's the difference between *"AI helps me write code"* and *"AI runs the loop while I make decisions."*

## Pattern 6 — Documentation as a deliverable

I treat README and CHANGELOG updates as part of the feature, not a follow-up. Same-day docs are the only ones that ever happen on a side-project.

This is also where AI assistants are uniquely good. They remember exactly what they just built. They have all the context. They'll write the README change *better* than you would, because they're working from the implementation, not from memory.

Late in the session I asked Claude to backfill the CHANGELOG to project inception. That's hours of code archaeology — walking the git log, consolidating intermediate work commits, attributing changes to the right PRs, classifying everything as Added/Changed/Removed/Fixed. One prompt, one PR, done. I'd never have done it by hand.

If your AI assistant is doing the implementation but not the docs, you're leaving a lot of value on the table.

## The session, end to end

Six patterns, applied to one morning's work. Here's the arc:

- **09:00** — *"Research audio bible api options."* Fifteen minutes later I have a survey of seven options with verdicts.
- **09:20** — Devil's-advocate prompt kills translation parity. Goal shrinks to *"one good audio source for every reference."*
- **09:30** — *"What's the easiest path to listen to that specific verse?"* Answer: the ESV API.
- **09:35** — Claude scaffolds `/api/verse-audio` as a near-copy of the existing `/api/verse` proxy. Inline `<audio>` lands in the verse panel. Crossway citation rendered alongside.
- **09:45** — Push to prod. I test on my phone. Audio works.
- **10:00** — Realisation: the same Crossway API key powers ESV *text* at `/passage/text/`. Half-hour upgrade adds ESV as a reading translation.
- **10:30** — UX fixes: an "ESV Audio" pill so the audio-translation contract is visible; Originals mode auto-switches the translation to KJV (Strong's tagging is KJV-only, which made the toggle look broken on ESV); ESV text omits inline `[N]` verse markers because the panel header already names the range.
- **11:00** — Same pattern extended to the Eagle Method book pages — ESV text and a *toggleable* audio player. Toggle defaults off, because the page shows five-plus verse cards in a grid and always-on audio would be visual noise.
- **11:30** — README updated. CHANGELOG started, then backfilled to project inception.
- **11:50** — Done. Ten PRs merged: [#16](https://github.com/adamswbrown/bible-tour/pull/16) through [#25](https://github.com/adamswbrown/bible-tour/pull/25).

Two new API routes. One new translation. One new toggle. Zero new dependencies. Two hours.

## What I take away from this

A few things I've come to believe after building most of an app this way.

**Constraints that ship beat goals that don't.** Translation parity was the ambitious goal. One translation that works everywhere was the shipped product. That's not a compromise; it's the right answer.

**Free upgrades compound.** Once the Crossway key was in production for audio, ESV text was a half-hour add. Look for these wherever an integration's surface area is small.

**Toggles are a real design tool, not a hedge.** The Eagle audio toggle isn't *"we couldn't decide"*. It's the right UX for a dense grid where always-on audio would clutter the page.

**Open prompts produce better research than narrow ones.** *"Research X"* gives a survey. *"Implement X"* jumps straight to code and skips the part where you decide whether X is even the right thing.

**Devil's advocate is the highest-ROI prompt I know.** The five points that killed my translation-parity goal would have cost me a week of work each on their own.

**Tell the model what kind of answer you want.** *"Easiest."* *"Most architecturally consistent."* *"Convince me of my options."* *"Play devil's advocate."* Constraints like these are how you get opinionated output instead of waffle.

**Treat the model like a senior collaborator, not a junior coder.** Hand it scope decisions and licence to push back. It will, if you let it. Most users don't.

**Ship the docs in the same session as the code.** The model has the context; you have the momentum. Both fade fast.

**Let the model run the release loop.** PRs, CI signals, merges, Vercel deploys — none of that needs to come back to you. Subscribe to the webhook activity, set the merge policy, stay in the strategic loop.

The meta-lesson: building with AI doesn't mean *automating the act of coding*. Anyone can prompt for code. It means **automating the engineering loop around the coding** — research, scoping, branching, CI, deploy, docs — so the only thing left for you to do is product judgement.

I made decisions for two hours this morning. Claude turned each decision into a shipped PR. That ratio is the real win, not the lines of code.

---

*[Tour of the Bible](https://bible-tour.vercel.app) is a fan-built companion to Matt Whitman's [Lightning-Fast Field Guide to the Bible](https://www.thetmbh.com/tourofthebible). Code at [github.com/adamswbrown/bible-tour](https://github.com/adamswbrown/bible-tour). Built by [Adam Brown](https://askadam.cloud/) and Claude.*
