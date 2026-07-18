# generate-wiki

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![agent-skill](https://img.shields.io/badge/agent--skill-8A2BE2)
![architecture](https://img.shields.io/badge/architecture-blue)
![documentation](https://img.shields.io/badge/documentation-blue)
![wiki](https://img.shields.io/badge/wiki-blue)

Internal architecture wikis are usually written once and then rot as the
code moves on. This skill builds one instead, and keeps it honest: one
markdown page per subsystem, each covering that subsystem's Architecture,
Runtime Flows, PR-traceable Key Decisions, and Source Anchors, wired
together by a hub `README.md` and a mechanical check script. It has two
modes. In **generate** mode, it produces the wiki from scratch: it mines
the actual codebase for each subsystem (source directories, `git
log`/PR history, and any design docs you point it at), then writes each
page through per-page implementer and factual-reviewer subagent pairs, so
pages stay grounded in that material instead of getting fabricated. In
**refresh** mode, it re-scans each page's Source Anchors for drift,
diffing `git log` against the paths a page cites (not timestamps or
versions), and updates only the pages that actually fell out of sync.

It follows the open [Agent Skills](https://agentskills.io) format, so it
isn't tied to any single agent: any runtime with subagent dispatch, file
read/write, and a structured user-question tool can run it. Claude Code is
the primary tested environment and is used for the install instructions
below.

## Install

For Claude Code, copy or symlink this folder into
`~/.claude/skills/generate-wiki` (available in every project) or
`<project>/.claude/skills/generate-wiki` (project-scoped only). For other
agents that support the Agent Skills format, follow that agent's skill
install convention. The only requirement is this folder's `SKILL.md` +
`references/` + `assets/` layout.

## Usage

- `/generate-wiki` runs generate mode: interview, scaffold, per-page
  pipeline, cross-link pass, final review, handoff.
- `/generate-wiki refresh --dry-run` runs refresh in report-only mode:
  print the drift table, touch nothing.
- `/generate-wiki refresh --pages a,b` restricts refresh to the named pages.
- `/generate-wiki --dir <path>` sets the wiki output directory (default
  `wiki`).

## How it works

Three layers:

1. **`SKILL.md`** is the orchestration layer: mode detection, the G1–G7 generate
   pipeline (preflight, interview, scaffold, per-page loop, cross-link,
   final review, handoff) and the R1–R3 refresh pipeline (drift detection,
   report, update loop).
2. **`references/`** holds the dispatch templates handed verbatim to each subagent:
   `binding-rules.md` (anti-fabrication + sourcing priority), plus
   `page-implementer.md`, `page-reviewer.md`, `cross-linker.md`, and
   `final-reviewer.md`.
3. **`assets/`** holds the files materialized into the target repo:
   `TEMPLATE.md` (per-page skeleton), `hub-template.md` (README hub),
   `check-wiki.sh.tmpl` (mechanical link/section check).

## Origin

Extracted from the process used to generate agentverse's internal
architecture wiki (PR #31, merged 2026-07-07).

## License

MIT. See `LICENSE`.
