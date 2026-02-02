---
title: "Building ProPresenter Lyrics Export: Solving a Real Problem for Worship Teams"
date: 2026-02-02T10:00:00Z
draft: false
hero: images/posts/propresenter-lyrics-export/hero.svg
description: "How a weekend frustration turned into a cross-platform desktop app and CLI toolkit for exporting lyrics from ProPresenter."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "ProPresenter lyrics export tool interface"
tags: ["ProPresenter", "Electron", "TypeScript", "open-source", "worship", "church tech", "CLI", "cross-platform"]
categories: ["Projects", "Tech"]
summary: "How a weekend frustration turned into a cross-platform desktop app and CLI toolkit for exporting lyrics from ProPresenter."
---

*How a weekend frustration turned into a cross-platform desktop app and CLI toolkit*

---

## The Problem Nobody Talks About

If you've ever worked on a worship team at a church, you know ProPresenter. It's the industry-standard presentation software that powers Sunday services at thousands of churches worldwide. It handles lyrics, scripture, announcements, and media with impressive reliability.

But here's the thing nobody mentions in the glossy product demos: **getting your lyrics back out of ProPresenter is surprisingly difficult.**

You've spent hours meticulously entering song lyrics, organizing them into verses, choruses, and bridges. You've built beautiful presentations with perfect timing. But then you need those lyrics somewhere else—maybe for:

- **Printing lyric sheets** for the worship band
- **Creating handouts** for congregation members
- **Archiving setlists** for future reference
- **Sharing lyrics** with team members who don't have ProPresenter
- **Building presentation slides** for other platforms

ProPresenter stores everything in its own proprietary format. Copy-paste is tedious. Manual transcription is error-prone. There had to be a better way.

## The Spark: ProPresenter's Hidden API

The breakthrough came from discovering that ProPresenter 7 has a **Network API**—a hidden feature that lets external applications connect and interact with running presentations. Buried in the settings menu, this API opens up programmatic access to playlists, presentations, slides, and real-time status updates.

The [renewedvision-propresenter](https://github.com/renewedvision/propresenter-js-sdk) package provided the foundation—a JavaScript SDK that wraps this API in a developer-friendly interface. Building on top of it, I could focus on the actual problem: extracting and exporting lyrics.

## Architecture: Simplicity First

The core design philosophy was straightforward: **do one thing well**.

```
ProPresenter → Network API → Extract Lyrics → Export Format
```

Three main components emerged:

1. **ProPresenter Client** - Handles all communication with ProPresenter's API, including connection management, playlist fetching, and presentation retrieval.

2. **Lyrics Extractor** - The intelligent parser that transforms raw presentation data into structured lyrics. This is where the magic happens—distinguishing actual song lyrics from scripture references, announcements, and other content.

3. **PPTX Exporter** - Generates clean, professionally-styled PowerPoint files ready for printing or projection.

The lyrics extractor uses heuristics to identify what's actually a lyric slide versus other content:

```typescript
// Check for common lyric section names
const lyricSectionPatterns = [
  /verse/i, /chorus/i, /bridge/i,
  /pre-?chorus/i, /tag/i, /outro/i,
  /intro/i, /hook/i, /refrain/i
];

// Filter out non-lyrics
const announcementPatterns = [
  /^welcome/i, /^announcements?/i,
  /www\./i, /https?:\/\//i
];
```

This approach means you get clean lyrics output without manually filtering out "Welcome!" slides and website URLs.

## From CLI to Desktop App: An Evolution

The project started as a command-line tool. For power users and automation scenarios, the CLI remains incredibly useful:

```bash
# Interactive playlist selection
propresenter-lyrics pptx

# Direct export with custom filename
propresenter-lyrics pptx 3 "Sunday Morning Worship"

# Export as JSON for further processing
propresenter-lyrics export --json
```

But command-line tools have a barrier to entry. Not everyone is comfortable opening a terminal, and installation can be tricky across different operating systems.

Enter **Electron**.

The desktop app wraps the same core functionality in a friendly graphical interface. Users can:
- Enter their ProPresenter connection settings visually
- Browse and select playlists with a click
- Preview songs before exporting
- Customize PowerPoint styling (fonts, colors, sizes)
- Export with one button press

The Electron architecture separates concerns cleanly:
- **Main process** handles file system operations and the core export engine
- **Renderer process** (React) provides the user interface
- **Preload script** bridges security between the two

Settings persist between sessions using `electron-store`, so users configure once and forget.

## The Bundling Challenge

One of the most frustrating technical challenges was **bundling the CLI into standalone executables**. The goal was simple: users download one file, run it, done. No Node.js installation, no npm, no dependencies.

The tool of choice was [pkg](https://github.com/vercel/pkg), which compiles Node.js projects into native executables. It worked beautifully—until it didn't.

The PowerPoint generation library (`pptxgenjs`) uses dynamic file system operations internally. When bundled with pkg, these operations break because the bundled "file system" isn't a real file system. Version 3.11.0 and later introduced changes that made bundling impossible.

The solution? **Lock the dependency at version 3.10.0** and disable features that rely on the problematic code paths:

```typescript
// Skip image encoding to avoid bundling issues with pkg
// if (logoBase64) {
//   slide.addImage({
//     data: `image/png;base64,${logoBase64}`,
//     ...
//   });
// }
```

Yes, this means CLI executables can't embed logos in the PowerPoint output. But they work reliably across macOS (ARM64 and Intel) and Windows. That tradeoff was worth it.

## Export Formats: Meeting Users Where They Are

Different workflows need different formats. The tool supports three:

**PowerPoint (.pptx)** - The most popular option. Generates professional slides with:
- Customizable fonts (default: Red Hat Display)
- Configurable text styling (bold, italic, color)
- 16:9 widescreen layout
- Song titles as section headers
- Section names (Verse 1, Chorus) in presenter notes

**Plain Text** - Simple, universal format organized by section:
```
=== Amazing Grace ===

[Verse 1]
Amazing grace how sweet the sound
That saved a wretch like me

[Chorus]
...
```

**JSON** - Structured data for developers and automation:
```json
{
  "title": "Amazing Grace",
  "uuid": "abc123",
  "sections": [
    { "name": "Verse 1", "slides": [...] }
  ]
}
```

## Cross-Platform by Design

Worship teams use Macs. Tech directors prefer Windows. Production volunteers bring whatever laptop they have. The tool needed to work everywhere.

For the desktop app, Electron handles cross-platform concerns automatically. The GitHub Actions workflow builds:
- macOS: `.zip` containing the `.app` bundle
- Windows: `.exe` installer

For the CLI, pkg generates three separate binaries:
- `propresenter-lyrics-macos-arm64` (Apple Silicon)
- `propresenter-lyrics-macos-x64` (Intel Macs)
- `propresenter-lyrics-win-x64.exe` (Windows)

Automated releases trigger on version tags, building everything in parallel and publishing to GitHub Releases.

## Real-World Impact

This tool has transformed my own workflow. Before a Sunday service, I can:

1. Open ProPresenter with my prepared setlist
2. Run a single command (or click one button)
3. Have a formatted PowerPoint file ready for the band in seconds

What used to take 20 minutes of tedious copy-pasting now takes 20 seconds.

The JSON export has enabled even more creative uses:
- Building custom lyric display apps
- Integrating with church management software
- Creating searchable lyric archives
- Generating chord charts from combined data sources

## Lessons Learned

**1. Start with the problem, not the technology.** The best developer tools solve real pain points. I built this because I needed it.

**2. Embrace constraints.** The pptxgenjs bundling issue forced a simpler approach. Sometimes limitations lead to better solutions.

**3. Meet users where they are.** Not everyone wants to use a terminal. The Electron app dramatically lowered the barrier to entry.

**4. Automate releases early.** GitHub Actions paid for itself immediately. No more manual builds across three operating systems.

**5. Document as you go.** Clear documentation (README, CLAUDE.md, inline comments) made the project maintainable and contributed to its usefulness.

## Try It Yourself

ProPresenter Lyrics Export is [open source on GitHub](https://github.com/adamswbrown/propresenterlyricexport). Download the desktop app or CLI executables from the Releases page, or run from source if you prefer.

Requirements are minimal:
- ProPresenter 7 running with Network API enabled
- That's it

Whether you're a worship leader preparing for Sunday, a tech director building automation, or a developer curious about the ProPresenter API, I hope this tool saves you time.

---

*Have questions or feedback? Open an issue on GitHub. Contributions welcome.*
