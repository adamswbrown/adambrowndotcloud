---
title: "Building the Azure Architecture Recommender: From Assessment Data to Ranked Patterns"
date: 2026-02-14T10:00:00Z
draft: true
hero: images/posts/building-azure-architecture-recommender/hero.svg
description: "Turning Dr. Migrate assessment exports into ranked, explained matches against ~50 reference architectures from the Azure Architecture Center."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A diagram mapping an application to Azure reference architectures"
tags: ["azure", "architecture", "python", "streamlit", "dr-migrate", "appcat"]
categories: ["Projects", "Cloud"]
---

> **Disclosure:** I work for [Altra](https://drmigrate.com), the company behind Dr. Migrate. This tool consumes Dr. Migrate assessment exports, which is worth flagging up front. The project is a personal side-project — opinions and weekend commits are my own.

## The question this tries to answer

"We've assessed this application. What's the right Azure architecture for it?"

That question gets asked a hundred times a week across partners, account teams, and customers. The honest answer involves reading the assessment, understanding the app, skimming the [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/browse), and making a judgement call. The dishonest answer is "AKS" regardless of what the data says.

I wanted something in between — a tool that reads the assessment, applies opinionated scoring against the catalogue of reference architectures, and hands back a *ranked, explained* shortlist that a human can sense-check.

> 📦 **Repo:** [github.com/adamswbrown/azure-architecture-categoriser](https://github.com/adamswbrown/azure-architecture-categoriser)

## How it works

1. **Upload** a Dr. Migrate context file — either an AppCat-generated context (Java/.NET) or a Dr. Migrate data export (any application).
2. **Review** the detected technologies, servers, and modernisation assessment it pulled out.
3. **Answer optional questions** to refine recommendations — availability requirements, security posture, cost priorities, runtime preference.
4. **Get ranked results** against ~50 reference architectures, with match scores, the reasoning behind each, potential challenges, links to the official docs, and a PDF export for stakeholders.

## What made this hard

**The catalogue is a moving target.** Microsoft keeps evolving the Architecture Center. Patterns get added, renamed, or quietly deprecated. The tool now supports loading the catalogue remotely from a blob-storage URL so it can update without a redeploy.

**Scoring is multi-dimensional.** I landed on dimensions like runtime model, modernisation depth, security alignment, cost optimisation, and availability expectations. Each contributes a sub-score with configurable weights. An SLO bonus signal biases toward patterns that explicitly target your availability tier. The GUI exposes a security-alignment slider so account teams can show customers the trade-off live.

**Explanations matter more than scores.** A 78% match means nothing on its own. The tool generates an explanation per recommendation — what it matched on, what it didn't, and what to watch out for. Those explanations are the thing account teams actually paste into proposals.

**AppCat and Dr. Migrate exports look very different.** AppCat is Java/.NET-centric with modernisation findings baked in. Dr. Migrate exports are broader but shallower per-application. I had to normalise both into a single internal context model before scoring anything.

## The 2.0 pivot

Version 2.0 added content insight dimensions and the SLO bonus signal, which changed the tone of the recommendations materially — patterns that previously ranked middling started winning deserved top spots when the underlying workload genuinely needed five-nines. It also moved documentation to GitHub Pages, because Streamlit's built-in documentation viewer wasn't cutting it for a tool that people increasingly used without me in the room.

## Who it's for

Presales architects, partner technical teams, and anyone who needs to defend a "pattern X is right for this workload" conversation with something better than vibes.

PRs and issues very welcome — especially new pattern contributions.
