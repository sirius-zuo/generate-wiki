---
name: generate-wiki
description: Use when asked to generate an internal architecture wiki, document subsystem architecture with decision records, or refresh/audit an existing wiki/ for drift. Builds one page per subsystem (architecture, runtime flows, PR-traceable key decisions, source anchors) via per-page implementer + factual-reviewer subagents. Modes: generate (default), refresh [--dry-run] [--pages a,b].
argument-hint: '[refresh] [--dry-run] [--pages page1,page2] [--dir wiki]'
allowed-tools: Agent, Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion
---

## Overview

Builds an internal architecture wiki: one markdown page per subsystem
(architecture, runtime flows, PR-traceable key decisions, source anchors),
wired together by a hub `README.md` and a mechanical check script. Two
modes: **generate** builds a wiki from scratch; **refresh** detects drift
via each page's Source Anchors and updates only what changed. Below,
`<skill>/` means this skill's own directory (where this file, `references/`,
and `assets/` live) — distinct from `<dir>`, the target repo's wiki output
directory. Before doing anything else, make a todo list: one item per
numbered step of the active mode (G1–G7, or R1–R3), once Step 0 has
determined which mode is active.

## Step 0 — Parse arguments & detect mode

`$ARGUMENTS` starting with `refresh` → refresh mode; anything else
(including empty) → generate mode. From the remaining arguments strip and
record: `--dry-run` (refresh only), `--pages a,b` (restricts refresh to the
named pages), `--dir <path>` (wiki directory, default `wiki`). In refresh
mode, if `<dir>/README.md` does not exist, stop and tell the user to run
generate first — there is nothing to refresh.

## Generate G1 — Preflight

Verify: current directory is inside a git repository; the Agent tool is
available. If the working tree is dirty, use AskUserQuestion to confirm
before proceeding — never assume. Probe capabilities: `gh auth status`
sets whether the PR-body sourcing tier (binding rules §2) exists this run.
Probe for design-doc directories at the repo root — `docs/`, `doc/`,
`design/`, `adr/`, `rfcs/` — existence only; which (if any) to mine is
confirmed in G2. Create the working branch (default `docs/internal-wiki`,
name confirmed in G2). Ensure `.generate-wiki/` is listed in the target
repo's `.gitignore`, appending it if not — this run-state directory
(ledger, briefs, reports, diff packages) must never be committed.

## Generate G2 — Interview

Before asking anything, auto-derive a page-set proposal: enumerate
subsystems from workspace/package manifests, or top-level source
directories if the ecosystem exposes no manifests, and propose one page
per subsystem with a one-line "covers" note. Then run exactly ONE
AskUserQuestion round, up to 3 questions:

1. Approve or adjust the proposed page set (merge, split, add, drop).
2. Confirm the output directory (`<dir>`) and branch name.
3. Confirm sourcing inputs: which design-doc directories to mine (and
   whether they're tracked), and whether PR history is meaningful here.

After this round the run is fully autonomous — no further questions in
generate mode.

## Generate G3 — Scaffold

Materialize the three assets into the target repo:

- `assets/TEMPLATE.md` → `<dir>/TEMPLATE.md`, copied as-is.
- `assets/hub-template.md` → `<dir>/README.md`, all five `{{...}}` tokens
  filled: `{{PROJECT_NAME}}`; `{{SYSTEM_DESCRIPTION}}` (two paragraphs
  drafted from repo exploration); `{{WIKI_DIR}}` = `<dir>`; `{{CRATE_DAG}}`
  — mermaid `graph TD` edges derived from real manifest dependencies, never
  invented; `{{PAGE_INDEX}}` — a `| Page | Covers | Summary |` table, one
  row per approved page, with provisional summaries (finalized in G5).
- `assets/check-wiki.sh.tmpl` → `scripts/check-wiki.sh` mode 0755 (or
  `<dir>/check-wiki.sh` if the repo has no `scripts/` convention), rendered
  with the exact command:
  ```bash
  sed -e "s|{{CANONICAL_PAGES}}|$PAGES|g" -e "s|{{WIKI_DIR}}|$DIR|g" <skill>/assets/check-wiki.sh.tmpl > scripts/check-wiki.sh
  ```
  where `$PAGES` is the space-separated approved page filenames and `$DIR`
  is `<dir>`. Call this rendered script's path `$CHECK` for the rest of
  this document — invoke as `$CHECK [page.md ...]` (no args checks every
  page except README/TEMPLATE; named args check only those pages).

One commit: scaffold.

## Generate G4 — Per-page loop

Sequential — one page at a time, never parallel: each page's commit
becomes the next page's `git log` context, and parallel dispatch risks two
pages colliding on the same cross-link or terminology choice. For each
approved page `<name>` (file `<name>.md`):

a. **Explore & compose the brief** at
   `BRIEF_PATH = .generate-wiki/page-<name>-brief.md`: a source table
   (directories/modules covered, design docs to mine, PRs/commits from
   `git log --oneline -- <dirs>` plus `gh pr list` when available),
   minimum flows, minimum decisions. Briefs are floors, not ceilings.
b. Record `BASE=$(git rev-parse HEAD)`.
c. Dispatch an implementer subagent on **a mid-tier model (in Claude Code:
   sonnet)** from `references/page-implementer.md`, filling all seven
   slots: `<<BRIEF_PATH>>` = the brief from (a); `<<WIKI_DIR>>` = `<dir>`;
   `<<PAGE_FILE>>` = `<name>.md`; `<<STYLE_REF>>` = the previous page's
   filename, or the literal string "none — you are writing the first page"
   for the first page; `<<CHECK_CMD>>` = `$CHECK <name>.md`;
   `<<BINDING_RULES>>` = the full verbatim contents of
   `references/binding-rules.md`; `<<REPORT_PATH>>` =
   `.generate-wiki/report-<name>.md`.
d. Generate the diff package:
   `git diff $BASE..HEAD > .generate-wiki/review-<name>.diff` — this path
   is `DIFF_PACKAGE_PATH`.
e. Dispatch a reviewer subagent on **a mid-tier model (in Claude Code:
   sonnet)** from `references/page-reviewer.md`, filling all six slots:
   `<<BRIEF_PATH>>` = same brief as (a); `<<REPORT_PATH>>` = the
   implementer's report from (c); `<<DIFF_PACKAGE_PATH>>` = the diff from
   (d); `<<BINDING_RULES>>` = `references/binding-rules.md` verbatim;
   `<<MIN_COVERAGE>>` = the brief's minimum flows and decisions, restated
   inline; `<<CHECK_CMD>>` = same value as (c).
f. Critical/Important findings → dispatch ONE fix subagent on **a mid-tier
   model (in Claude Code: sonnet)** with the complete findings list and the
   binding rules, appending to the same `REPORT_PATH`; regenerate the diff
   package with `git diff $BASE..HEAD > .generate-wiki/review-<name>.diff`;
   then re-dispatch the reviewer with the same slots. Minors → record in the
   ledger for final-review triage; do not fix now.
g. Append one line to `.generate-wiki/progress.md`:
   `Page <name>: complete (commits X..Y, review <outcome>); minors: ...;
   findings: ...`.

**Crash recovery:** on invocation, read `.generate-wiki/progress.md` first.
Pages it marks complete are skipped — never regenerate a ledger-complete
page. A page with an uncommitted draft (`git status` shows the page file)
is resumed: re-dispatch from Step D (Check) of the implementer's procedure
onward.

## Generate G5 — Cross-link pass

Dispatch ONE subagent on **a mid-tier model (in Claude Code: sonnet)** from
`references/cross-linker.md`, once, after every page is implemented and
reviewed, filling all four slots: `<<WIKI_DIR>>` = `<dir>`; `<<CHECK_CMD>>`
= `$CHECK` (no page arguments, checks every page); `<<BINDING_RULES>>` =
`references/binding-rules.md` verbatim; `<<REPORT_PATH>>` =
`.generate-wiki/cross-link-report.md`. Then the controller verifies
directly — no reviewer dispatch for this pass: `$CHECK` green over all
pages; a fresh symmetric link-graph scan (re-run, not reused from the
subagent's report); zero stray design-doc paths; spot-check any new
sentence the pass introduced against source.

## Generate G6 — Final review

Build the whole-branch diff package:
`git diff <branch-base>..HEAD > .generate-wiki/final-diff.diff`
(`<branch-base>` is the commit G1's branch started from). Write
`.generate-wiki/triage.md`: every deferred Minor plus every real project
finding recorded in the ledger. Dispatch ONE subagent on **the most
capable available model** from `references/final-reviewer.md`, filling all
five slots: `<<WIKI_DIR>>` = `<dir>`; `<<CHECK_CMD>>` = `$CHECK`;
`<<DIFF_PACKAGE_PATH>>` = `.generate-wiki/final-diff.diff`;
`<<LEDGER_PATH>>` = `.generate-wiki/progress.md`; `<<TRIAGE_PATH>>` =
`.generate-wiki/triage.md`. This is a read-only review — it must not touch
the working tree. For its findings, dispatch ONE fix subagent on **a
mid-tier model (in Claude Code: sonnet)** covering the complete list (the
controller may apply single-sentence fixes directly instead). Re-run all
gates after fixes land.

## Generate G7 — Handoff

Re-run every gate one final time. Summarize for the user: pages built,
each page's review outcome, and — as a first-class output, not an aside —
the **real project findings** list (dead code, unwired features, stale
comments, spec drift) surfaced during the run, with a suggestion to file
follow-up tickets. Offer to push the branch and open a PR; never execute
either without the user's explicit confirmation.

## Refresh R1 — Drift detection

For each page in `<dir>` (or only the `--pages` subset, if given): parse
its Source Anchors section into a bullet path list.
`LAST=$(git log -1 --format=%H -- <dir>/<page>)`.
`git log --oneline $LAST.. -- <anchor paths>` non-empty → **drifted**. An
anchor path that no longer exists on disk → **hard drift**, flagged
separately. An anchor bullet that cannot be parsed as a path →
**un-refreshable**: report the parse problem for that page in R2, do not
guess at what it meant.

## Refresh R2 — Report / dry-run stop

Emit a drift table: page → drifting commits (with subjects) → hard-drift
anchors → un-refreshable notes. `--dry-run` ends the run here — the
working tree is untouched, nothing is committed.

## Refresh R3 — Update loop

For each drifted page (non-drifted pages are skipped entirely), run the
same G4 machinery (steps a–g, same slot-filling, same reviewer gate) with
two changes: the brief is a **refresh brief** — the drift evidence from R1
(the commits/PRs that touched the page's anchors, plus `gh pr view` bodies
when available) — instead of a from-scratch source table; and the
implementer follows refresh-specific rules layered onto the binding rules:
update only what actually changed; new Key Decision entries are added
newest-first; NEVER rewrite or delete an existing decision entry — it is
history; update Source Anchors for paths that moved; document removed
functionality honestly rather than deleting its record. Run the cross-link
check (G5, mechanical verification only) only for pages whose link set
changed. One commit per refreshed page.

## Model selection

Page implementers, page reviewers, fix subagents, and the cross-linker
dispatch on **a mid-tier model (in Claude Code: sonnet)**. The final
whole-wiki review (G6) dispatches on **the most capable available model**.
The controller never inherits its own session's model into a dispatch
implicitly — every Agent call above names its model explicitly.

## Error handling

- **Subagent dies mid-task:** work is recoverable — committed pages are in
  git, `.generate-wiki/progress.md` names them; an uncommitted draft is
  found via `git status` and resumed. Never regenerate a page the ledger
  marks complete.
- **No `gh` / unauthenticated:** sourcing degrades per binding rules §2
  (design docs → commit archaeology → the fallback phrasing); generation
  proceeds without PR bodies.
- **Check script fails inside a page task:** the implementer fixes it at
  its own Step D (Check) before committing; a failure that reaches the
  controller (G4 step f already ran once) is a fix-cycle trigger, not a
  crash.
- **Dirty tree at preflight:** ask, don't assume (G1).
- **Malformed Source Anchors during refresh:** flag as un-refreshable
  (R1); never guess the intended path.
