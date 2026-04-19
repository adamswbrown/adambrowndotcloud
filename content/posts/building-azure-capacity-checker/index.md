---
title: "Building Azure Capacity Checker: Closing the Migration-Day Gap"
date: 2026-03-02T10:00:00Z
draft: false
hero: images/posts/building-azure-capacity-checker/hero.svg
description: "Rightsizing exports say a VM size is available. Azure on migration day sometimes disagrees. Here's the tool I built to find out which is lying — before you need the answer."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "A cloud infrastructure dashboard validating VM availability"
tags: ["azure", "cloud-migration", "python", "streamlit", "rightsizing"]
categories: ["Projects", "Cloud"]
---

> **Disclosure:** I work for [Altra](https://drmigrate.com), the company behind Dr. Migrate. This project reads Dr. Migrate rightsizing exports, so that's worth naming up front. The tool itself is a personal side-project — opinions, bugs, and weekend commits are my own.

## The problem nobody tells you about until migration day

You run a rightsizing exercise. You get a lovely Excel file with 1,200 servers each mapped to a neat Azure VM SKU. Sign-off happens. Change windows go in the calendar. Migration day arrives. And then you discover that the `Standard_D4s_v5` you planned for 300 servers is *allocated out* in your target region — or worse, not available in that region at all, or not available on your subscription tier — and the whole plan wobbles.

The catalogue data that rightsizing tools use is true *in general*. It isn't always true *in your region, on your subscription, today*.

Azure Capacity Checker exists to answer that question *before* migration day rather than during it.

> 📦 **Repo:** [github.com/adamswbrown/AzureCapacityChecker](https://github.com/adamswbrown/AzureCapacityChecker)

## What it actually does

1. **Upload** a rightsizing export — the Excel format from Azure Migrate or Dr. Migrate, or a generic CSV/JSON.
2. **Catalogue check** — for every SKU in the export, query the Azure Resource SKUs API to confirm it's available in your target region and subscription.
3. **Live capacity check** (optional) — submit ARM deployment *validation* requests to test whether physical hardware is actually allocatable right now. No VMs are created; it's a dry-run that Azure either accepts or rejects based on current capacity.
4. **Alternative recommendations** — when a SKU is blocked or exhausted, score and rank alternatives by family similarity, vCPU and memory match, generation, and disk support.
5. **Pricing comparison** — PAYG, 1-year RI, and 3-year RI pricing from the Azure Retail Prices API for both the current SKU and its alternatives.
6. **Export** — download an updated output with blocked SKUs swapped for verified alternatives, mirroring the original rightsizing Excel format.

## The interesting bits

**Authentication was the hardest part.** Streamlit apps get deployed in all sorts of places — a laptop, a VM, Streamlit Cloud, an internal container. Each has a different idea of what "logged in to Azure" means. I ended up supporting four auth methods: default credentials (CLI / managed identity / env vars), device code flow, interactive browser, and service principal. Device code became the default for hosted environments because it's the only one that works reliably when there's no browser on the machine running the app.

**The live capacity check is a trick.** ARM has a validation endpoint that runs the allocation check without provisioning. That's the mechanism this tool leans on — it's the same call Azure itself makes internally before it commits to creating your VM. If it says no now, it'll say no on migration day.

**Alternative ranking is where the judgement lives.** Swapping a `D4s_v5` for a `D4s_v4` is usually fine. Swapping it for a `B4ms` probably isn't. The scoring function weighs family, generation, vCPU/memory match, and premium disk support, and always shows the reasoning so a human can veto.

## Who this is for

Anyone running an Azure migration big enough that finding out on migration day would hurt. In practice: SMB account execs with 200+ server engagements, cloud teams doing lift-and-shift at scale, or partners preparing bids where the SKU numbers need to *actually* hold up.

Feedback, issues, and PRs welcome.
