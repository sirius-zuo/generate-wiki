# generate-wiki

A Claude Code skill that builds an internal architecture wiki: one markdown
page per subsystem (architecture, runtime flows, PR-traceable key decisions,
source anchors), wired together by a hub `README.md` and a mechanical check
script. Two modes: **generate** builds the wiki from scratch via per-page
implementer + factual-reviewer subagent pairs; **refresh** re-scans each
page's Source Anchors for drift and updates only the pages actually touched
— drift detection is anchor-based (it diffs `git log` against the paths a
page cites), not timestamp- or version-based.

## Install

Copy or symlink this folder into `~/.claude/skills/generate-wiki` (available
in every project) or `<project>/.claude/skills/generate-wiki`
(project-scoped only).

## Usage

- `/generate-wiki` — generate mode: interview, scaffold, per-page pipeline,
  cross-link pass, final review.
- `/generate-wiki refresh --dry-run` — refresh mode, report-only: print the
  drift table, touch nothing.
- `/generate-wiki refresh --pages a,b` — restrict refresh to the named pages.
- `/generate-wiki --dir <path>` — set the wiki output directory (default
  `wiki`).

## How it works

Three layers:

1. **`SKILL.md`** — orchestration: mode detection, the G1–G7 generate
   pipeline (preflight, interview, scaffold, per-page loop, cross-link,
   final review, handoff) and the R1–R3 refresh pipeline (drift detection,
   report, update loop).
2. **`references/`** — dispatch templates handed verbatim to each subagent:
   `binding-rules.md` (anti-fabrication + sourcing priority), plus
   `page-implementer.md`, `page-reviewer.md`, `cross-linker.md`, and
   `final-reviewer.md`.
3. **`assets/`** — files materialized into the target repo:
   `TEMPLATE.md` (per-page skeleton), `hub-template.md` (README hub),
   `check-wiki.sh.tmpl` (mechanical link/section check).

## Origin

Extracted from the process used to generate agentverse's internal
architecture wiki (PR #31, merged 2026-07-07).

## License

MIT — see `LICENSE`.
