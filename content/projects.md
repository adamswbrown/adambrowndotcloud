---
title: "Projects"
date: 2026-04-19
draft: false
description: "Public projects I'm building, tinkering with, or quietly maintaining."
type: projects
layout: single
enableTOC: false
intro: "A running list of the public things I'm working on. Some scratch an itch, some solve a customer problem, some are just fun to build. All of them are open on GitHub if you want to poke around, fork, or file an issue."
projects:
  - name: Meeting Reminder
    icon: fa-solid fa-bell
    description: "A menu bar app for macOS that nudges you out of flow and into your next meeting. Built for ADHD brains — progressive alerts escalate as the meeting gets closer, it detects when a call actually ends (not just when the calendar says it should), and it pulls context from Notion so you know what the meeting is about before you join."
    tech: ["Swift", "Python", "Notion API"]
    repo: https://github.com/adamswbrown/meeting-reminder
    post: /posts/building-meeting-reminder/
  - name: Azure Capacity Checker
    icon: fa-brands fa-microsoft
    description: "Closes a gap in the Azure sizing workflow. Takes rightsizing exports, checks them against live Azure SKU availability in the target region, actually tries to deploy to verify capacity is real, and suggests alternatives when a SKU isn't viable."
    tech: ["Python", "Azure SDK"]
    repo: https://github.com/adamswbrown/AzureCapacityChecker
    post: /posts/building-azure-capacity-checker/
  - name: Azure Architecture Categoriser
    icon: fa-solid fa-sitemap
    description: "Matches applications to Azure reference architectures from the Azure Architecture Center. Upload assessment data from Dr. Migrate, answer a handful of questions about the workload, get ranked recommendations with explanations for why each pattern fits."
    tech: ["Python", "Bicep", "Docker"]
    repo: https://github.com/adamswbrown/azure-architecture-categoriser
    post: /posts/building-azure-architecture-recommender/
  - name: ProPresenter Lyric Export
    icon: fa-solid fa-music
    description: "Extracts worship song lyrics from ProPresenter 7 and exports them as PowerPoint decks, JSON, or plain text. Cross-platform CLI with standalone executables so the church tech team doesn't need a Node install to use it."
    tech: ["TypeScript", "Node.js"]
    repo: https://github.com/adamswbrown/propresenterlyricexport
    post: /posts/propresenter-lyrics-export/
  - name: Tour of the Bible
    icon: fa-solid fa-book-bible
    description: "A web companion for Matt Whitman's Lightning-Fast Field Guide to the Bible — taste every book in about 90 minutes. Checklist across all 66 books with curated verse references, inline verse reader, multiple translations, and an Originals mode that surfaces Greek and Hebrew lemma data. No accounts, no database — progress lives in localStorage."
    tech: ["Next.js 16", "Vercel", "YouVersion API", "STEPBible"]
    repo: https://github.com/adamswbrown/bible-tour
    url: https://bible-tour.vercel.app
    post: /posts/building-bible-tour/
  - name: adambrown.cloud
    icon: fa-solid fa-globe
    description: "This site. A Hugo static site using the Toha theme, deployed to both Netlify and GitHub Pages. Source is public if you want to see how it's wired together or steal any of the layouts."
    tech: ["Hugo", "Go templates", "SCSS"]
    repo: https://github.com/adamswbrown/adambrowndotcloud
---
