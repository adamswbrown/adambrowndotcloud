---
title: "Two Files, One Habit: How Agentic Coding Projects Are Learning to Remember"
date: 2026-05-26T10:00:00Z
draft: false
description: "The state.md and worklog.md pattern that's quietly becoming the standard way to give coding agents durable memory across sessions."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: ["claude", "agents", "agentic-coding", "workflow", "patterns"]
categories: ["Productivity", "Engineering"]
---

This started over a cup of coffee. My friend has been working on the people side of agentic coding. How do you actually get a team of engineers good at these tools on a large codebase, instead of two enthusiasts loving them and everyone else quietly going back to their old habits? Training, enablement, the unsexy stuff that decides whether a tool sticks. That was the conversation. What works, what falls apart at scale, the patterns people are landing on for serious projects. At some point I mentioned what I do with state and worklog files, and the thing snowballed. He hadn't seen the pattern before. I'd been doing it for so long I'd stopped noticing it was a pattern. So I went home and started writing it down.

Here's what I told him.

The shape comes down to two files that sit next to your code and do the boring work of remembering what's going on. One is usually called `state.md`. The other is usually called `worklog.md`. The names vary. The pattern doesn't.

## Why this even exists

If you've used an agent like Claude Code or Codex for anything that takes more than one sitting, you already know the problem. You come back the next morning, fire it up, and it has no idea what you were working on. You explain. It nods. Two days later you do it again. After the fourth time you start writing yourself a little "where I left off" note and stuffing it in the project. Congratulations, you've reinvented the worklog.

Most teams figured this out independently, which is why the file names are inconsistent and the conventions are still settling. But once you've felt the pain, the fix is obvious: write things down, in the repo, in markdown, where the agent can read them at the start of the next session.

## The static layer is mostly solved

Before the dynamic stuff, there's the static layer, and that part is basically a done deal. `AGENTS.md` is the cross-tool convention now, stewarded by the Agentic AI Foundation under the Linux Foundation. OpenAI's Codex, Cursor, Aider, and most of the modern coding agents read it. Claude Code uses `CLAUDE.md` for the same purpose. Pick whichever your tool actually loads.

This file holds the things an agent can't infer: build commands, the testing convention, the linter you're using, which directories to leave alone, which library you prefer for HTTP. Things that don't change much. You write it once, prune it occasionally, and move on.

The interesting part is everything below this layer.

## The dynamic layer: state.md and worklog.md

The dynamic layer is where the convention hasn't fully landed. Different skills use different names. Once you squint past the naming, almost all of them are doing the same two things.

`state.md` (sometimes `plan.md`, `task_plan.md`, or `CONTINUITY.md`) is the live "where we are right now" file. It's short. It gets overwritten constantly. It answers: what's the goal, what's the active task, what's blocked, what's the current branch, what was the last thing decided. If you're picking it up fresh, this is what you read first.

`worklog.md` (sometimes `progress.md`, `SESSION_LOG.md`, `HANDOFF.md`, or daily files like `memory/YYYY-MM-DD.md`) is the chronological log. Append-only. Dated entries. What was done, what was decided, what was tried and abandoned, what's still open. This file gets long. That's fine. The point of the worklog isn't to be read top-to-bottom. It's to be searchable when the agent (or you) needs to remember why you ruled out a particular approach three weeks ago.

The Manus-style "planning-with-files" skill that got a lot of attention earlier this year splits the dynamic layer into three: `task_plan.md`, `findings.md`, and `progress.md`. That's a refinement of the same idea, where research notes get their own file so they don't bloat the worklog. Worth doing if your projects involve a lot of background reading.

## What goes in them

The schemas have converged more than the names. A typical `state.md` is short enough to read in under a minute:

- Goal in one or two sentences
- Current phase or milestone
- Active task with a status
- Blockers, if any
- Last decision made
- Pointer to where in the worklog the latest entry sits

A typical worklog entry has roughly this shape:

- Timestamp or date
- What was done
- Decisions made and why
- Dead ends and what we learned from them
- Open questions
- Next steps

The "dead ends" line is the one most people skip and then regret. It's the most valuable content in the file. Without it the agent will happily re-walk the same wrong path in two weeks.

A handful of skills wrap this in YAML frontmatter so the agent can parse it more reliably: `id`, `status`, `priority`, `dates`, `dependencies`, `tags`. It's worth it if you're going to have more than a few of these files. For a single project, plain markdown is fine.

## Here's what it looks like

Say you're building semantic search into your team's internal docs site. A few moving parts: an indexer that walks the docs and embeds them, a small search service, a UI change in the docs site itself. Multi-week work. Multiple agent sessions. Exactly the kind of thing this is for.

### CLAUDE.md (or AGENTS.md)

This barely changes. A few lines pointing the agent at the other two files, plus the usual rules.

```markdown
# Docs Search

Internal documentation search. Python + FastAPI service, Postgres with pgvector,
Next.js docs site (don't touch the design system).

## Where to look
- `state.md` — current state of the project, read this first
- `worklog.md` — chronological log of what's been done, scan the bottom

At session start: read state.md, then read the last worklog entry.
At session end: update state.md and append a worklog entry before stopping.

## Conventions
- Python: ruff + mypy strict. No mocks in tests; use docker-compose for integration.
- Commits: conventional commits, lowercase scope, no AI signatures.
- Don't run migrations against prod. Don't touch `infra/` without asking.
```

That's the whole thing. It's stable. You'll edit it twice a month at most.

### state.md

Short. Mutable. Overwrite freely.

```markdown
# State

**Goal:** Ship semantic search for internal docs. Phase 2 of 4.

**Active task:** Backfill embeddings for the existing 12k docs.
Script is written but hitting rate limits on the embedding API.

**Status:** Blocked. Need to decide between batching (slower, cheaper)
and a paid tier (faster, ~$80/month).

**Branch:** `feat/backfill-embeddings`

**Last decision:** Using OpenAI text-embedding-3-small over Cohere because
of the dimension count matching our pgvector index. Logged in worklog
2026-05-22.

**Pointer:** Most recent worklog entry is 2026-05-25.
```

If you open this and read nothing else, you know what's happening. That's the test.

### worklog.md

Append-only. Dated entries. This file grows forever and that's the point.

```markdown
# Worklog

## 2026-05-25

- Wrote the backfill script (`scripts/backfill_embeddings.py`).
- Tested on a 50-doc sample. Works. Embeddings landing in pgvector cleanly.
- Tried to run against the full set. Rate-limited at ~600 docs.
- Open question: pay for the higher tier or batch over a weekend?
- Next: Decide on rate limit approach, then kick off the full backfill.

## 2026-05-22

- Chose OpenAI text-embedding-3-small. Tried Cohere first but their 1024-dim
  output didn't match the pgvector index we already built around 1536. Not
  worth rebuilding the index.
- Dead end: tried to do this with a local model (bge-small) but quality on
  internal jargon was bad. Two hours wasted, won't try again unless we
  hit cost issues at scale.
- Decided not to chunk by paragraph yet. Whole-doc embedding is good
  enough for v1. Revisit if recall is poor.

## 2026-05-20

- Set up pgvector extension and the `doc_embeddings` table.
- Wrote a small `search.py` that does cosine similarity, returns top-k.
- Tested against five hand-picked queries. Results look reasonable.
- Next: figure out how to backfill the existing corpus.
```

A few things to notice. Every entry has dead ends or open questions, not just wins. The dates are real headings so the agent can grep for them. The pointers to files and decisions are precise. Nothing here is a transcript. It's the residue of the work, not a recording of it.

The first entry of any new project is usually just one bullet: "started the repo, set up the basics." That's fine. The pattern doesn't have to look impressive on day one. It has to be there when you come back on day three.

## Setting it up

The mechanics are unglamorous. Create three files at the root of your project. `CLAUDE.md` (or `AGENTS.md`, depending on your tool), `state.md`, and `worklog.md`. They sit next to your README.

Write the static file first. Keep it short. The most important part is the "where to look" pointer that tells the agent to read `state.md` and the last worklog entry at the start of every session, and to update them at the end. Without that pointer, the other two files are dead weight. The agent won't open them unless something tells it to.

Initialize `state.md` with one paragraph. What you're building, what you're doing right now, where things stand. If that's "starting fresh, nothing done yet," write exactly that. It updates fast anyway.

Initialize `worklog.md` with today's date and one bullet about what you're starting. Even if all you did was create the files, log it. The first entry sets the precedent that something always gets written.

Commit all three. They're project documentation, same as your README. If your repo is private and your teammates use the same agent, they get the same context you do. If it's public, anyone reading the repo gets a better picture of the actual state of the work than they'd get from any README. Don't gitignore them. The whole point is shared, durable memory.

Now start your first agent session. Tell it: "Read CLAUDE.md and follow its instructions." That's the prompt. The agent reads the static file, which tells it to read `state.md` and the last worklog entry, and you're off. At the end of the session, before you stop, ask it to update `state.md` and append a new worklog entry.

After two or three sessions of doing this manually, it becomes muscle memory. If you want to get fancier later, most agent tools have hook mechanisms (Claude Code has session-start and session-end hooks) where you can wire the read/update steps in so they happen automatically. I'd hold off on that for the first week. You'll learn what belongs in your worklog entries by writing them yourself before you automate.

## The habits that make this actually work

The mechanics are easy. The discipline is the hard part. A few things I keep seeing in the setups that hold up over time.

Write at session end. Read at session start. This is the whole loop. If you only do one of them, the system breaks. Most of the skills that work well include an explicit "wrap up" step that updates `state.md` and appends to the worklog before the session ends.

Keep `state.md` short and stable. Facts and bullets. No transcripts, no narrative, no "we explored several options and ultimately decided..." prose. That kind of writing belongs in the worklog. State is for the agent to orient itself in five seconds.

Don't duplicate the code. The agent can read your codebase. It cannot read what you tried last Thursday and abandoned. Write down the things that aren't recoverable from source.

Treat dead ends as first-class entries. The wrong turns are the highest-value content. If you only log successes, you've built a glorified changelog.

## What I'd actually pick today

Three files. One for the static rules, one for the live state, one for the chronological log.

The static file is the only one where the name depends on your tool. I use Claude, so for me that file is `CLAUDE.md`. If you're on Copilot, Codex, Cursor, Aider, or pretty much anything else, you want `AGENTS.md` instead. Same content, different filename. Use whichever your tool actually reads at the start of a session, otherwise you're writing into the void.

The other two are tool-agnostic. `state.md` for the live state, kept under 50 lines or so. `worklog.md` for the chronological log, append-only, dated entries. Those names work everywhere because no agent loads them automatically. You point at them from your static file ("at the start of a session, read `state.md` and the most recent worklog entry") and the agent does the rest.

If your projects involve a lot of research, peel `findings.md` off the worklog. Most of the more elaborate systems I've seen are this same three-file shape with things renamed or split.

The space will probably standardize further over the next year. `AGENTS.md` was nowhere two years ago and now it's everywhere. Something similar will likely happen on the dynamic side. My bet is on the planning-with-files three-file pattern, but I wouldn't wait for the dust to settle to start using something. The cost of picking "wrong" is almost zero. You rename a file when the convention lands.

The cost of not using anything is that your agent forgets what it was doing every morning, and you spend the first ten minutes of every session explaining yourself. Don't do that.
