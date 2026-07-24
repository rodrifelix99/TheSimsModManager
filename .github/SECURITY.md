# Security Policy

The Sims Mod Manager is a desktop app that reads and writes files on your
machine and parses **untrusted mod content** you download from the internet.
That makes its security posture worth taking seriously — this document explains
what we protect, how to report a problem, and what you can expect back.

## Supported versions

Only the [latest release](https://github.com/rodrifelix99/TheSimsModManager/releases/latest)
is supported. Fixes ship in a new release rather than as patches to older
versions, so the first step for any security issue is usually "update to the
latest build." The app checks for updates on launch and links you to the
newest release.

## Reporting a vulnerability

Please **do not** open a public issue for security problems. Instead, use
GitHub's private reporting:
**[Report a vulnerability](https://github.com/rodrifelix99/TheSimsModManager/security/advisories/new)**.

A good report includes:

- The app version (see **Settings → About**) and your OS.
- Steps to reproduce, and the impact you believe it has.
- If relevant, a **sample mod or archive file** that triggers the issue. The
  app parses untrusted `.package` files and extracts untrusted archives, so
  parser and extraction bugs are of particular interest — a minimal
  proof-of-concept file is the single most useful thing you can attach.

### What to expect

- **Initial response:** within 7 days.
- **Triage & assessment:** we'll confirm the issue, ask for anything missing,
  and agree on a rough severity.
- **Fix & release:** valid issues are fixed in the next release; we'll let you
  know when it ships.
- **Credit:** we're happy to credit you in the release notes and advisory
  (or keep you anonymous — your call).

Please give us a reasonable window to ship a fix before disclosing publicly.

## Security model

Understanding where the risk lives helps you report the issues that matter.

### Trust boundaries

The app treats the following as **untrusted input** and tries to handle it
defensively:

- **`.package` files** — parsed by a custom best-effort DBPF reader
  (`lib/src/core/package_insight.dart`) to extract embedded artwork and
  metadata. It runs in worker isolates over zlib/RefPack-compressed data. A
  malformed or malicious package must fail gracefully (return `null`), never
  crash the app or read outside the file.
- **Archives (`.zip`, `.rar`, `.7z`)** — extracted on install
  (`lib/src/core/mod_archive.dart`). Zip is decoded natively; rar/7z shell out
  to the system `tar` (bsdtar). Extraction **refuses zip-slip paths** (entries
  that escape the target directory) and only writes files matching the game's
  mod extensions.
- **Dropped files and folders** — drag-and-drop content is filtered to what
  the selected game can actually use before anything is written.

Anything read from disk — file names, folder names, package contents — is data,
not instructions, and should never be able to make the app write outside the
user-chosen mods directory.

### Network surface

The app makes a small, fixed set of outbound requests:

- **GitHub Releases API** — the launch update check and the feedback/issue
  links (`lib/src/services/github.dart`). Read-only, best-effort.
- **PostHog (EU Cloud)** — anonymous, opt-in analytics and error reporting
  (`lib/src/services/analytics.dart`).

The app does not run a listening server, does not open network ports, and does
not download or execute code at runtime. Updates are delivered only as new
releases the user chooses to install.

### Data & privacy

Analytics and error reporting are **opt-in** (Settings → "Share anonymous
usage data") and best-effort. When enabled, events carry only an anonymous
UUID plus counts, sizes, and game ids — **never mod names, file paths, or
search text**. Everything is gated on that single toggle. A privacy issue in
this pipeline (e.g. any path or filename leaking into an event) is in scope and
we'd like to hear about it.

## Scope

**In scope**

- Memory-safety / crash / path-traversal bugs in the DBPF parser or archive
  extraction reachable from untrusted mod files.
- Writing files outside the user-selected mods directory (zip-slip, symlink
  tricks, crafted folder names).
- Privacy leaks in analytics/error reporting (data escaping the stated
  contract).
- Command-injection or unsafe argument handling in the `tar` / PowerShell /
  `df` shell-outs.
- Anything that lets untrusted mod content run code or escalate privileges.

**Out of scope**

- Vulnerabilities in the games themselves, or in mods once they're installed
  and loaded by the game — the app installs files; it doesn't sandbox what a
  game does with them.
- Issues requiring a machine already compromised or an attacker with local
  admin.
- The safety of third-party mods you choose to download; we surface metadata
  but do not vet mod content.
- Denial-of-service that requires the user to deliberately open a
  pathologically large file (though crashes we can handle gracefully are still
  worth reporting).
- Social-engineering, physical access, or issues in GitHub / PostHog
  infrastructure itself.

## Staying safe as a user

- Install mods only from sources you trust; the app cannot vouch for mod
  content.
- Download the app itself only from the official
  [Releases page](https://github.com/rodrifelix99/TheSimsModManager/releases).
- Keep the app updated — security fixes ship only in the latest release.
