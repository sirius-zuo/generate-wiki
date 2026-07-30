---
name: spec-to-wiki
description: Use before substantive implementation exists to create or refresh an internal architecture wiki grounded only in confirmed specifications.
argument-hint: '[refresh] [--dry-run] [--pages page1,page2] [--dir wiki] [--spec <path>]'
allowed-tools: Agent, Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion
---

# Spec to Wiki

Build an internal architecture wiki from specifications before substantive
implementation exists. The wiki expresses intended architecture without
pretending that code has been verified. A later `code-to-wiki` run updates
these same pages to implementation truth and records material differences.

`<skill>/shared/` contains the canonical assets and common dispatch rules.
Run state lives in `.generate-wiki/` and must never be committed.

Before acting, create one todo per numbered step in the active mode: S1-S7
for generation or SR1-SR3 for refresh.

## S0: Parse arguments and mode

The first argument `refresh` selects refresh mode. Parse the remaining:

- `--dry-run`, refresh only.
- `--pages a,b`, refresh only.
- `--dir <path>`, default `wiki`.
- Repeatable `--spec <path>` inputs.

`spec-to-wiki refresh --dry-run` reports specification drift without edits.
In refresh mode require `<dir>/README.md`; otherwise stop and ask for an
initial generation run.

## S1: Preflight

Require a git repository and subagent dispatch. If the worktree is dirty,
ask the user to confirm before edits. Probe likely specification directories
at the repository root: `docs/`, `specs/`, `design/`, `adr/`, and `rfcs/`.
Existence makes a directory a candidate, not an authority.

Inspect manifests and conventional source roots for substantive
implementation. Documentation, configuration, generated stubs, empty
packages, declarations without behavior, and interface-only scaffolding do
not count. If substantive implementation exists, stop and recommend
`code-to-wiki`; never use code to fill gaps in specifications.

Create branch `docs/internal-wiki` after S2 confirms it. Record the branch
base in `.generate-wiki/branch-base`. Ensure `.generate-wiki/` is ignored.

## S2: One-round interview

Auto-derive a proposed page set from the confirmed specification structure:
major bounded systems, services, modules, or components become pages. For
each page give a one-line coverage note and the supporting spec paths.

Ask exactly one round of up to three questions:

1. Approve or adjust the proposed page set.
2. Confirm output directory and branch name.
3. Confirm authoritative specification inputs from discovered candidates
   and `--spec` arguments.

After this round, do not ask more generation questions. An ambiguity or
contradiction becomes a finding rather than an invented resolution.

## S3: Scaffold

Materialize:

- `<skill>/shared/assets/TEMPLATE.md` to `<dir>/TEMPLATE.md`.
- `<skill>/shared/assets/hub-template.md` to `<dir>/README.md`, rendering
  the project name, two-paragraph specification-grounded description,
  specification-declared dependency graph, and approved page index.
- `<skill>/shared/assets/check-wiki.sh.tmpl` to the repository's conventional
  scripts directory, or `<dir>/check-wiki.sh` when none exists.

Never invent a dependency edge absent from the confirmed specs. Commit the
scaffold once.

## S4: Sequential page loop

Process one page at a time. Each committed page becomes the style and history
context for the next.

For each page:

1. Write `.generate-wiki/page-<name>-brief.md` containing the confirmed spec
   sources and sections, minimum architecture claims, flows, decisions, and
   all known ambiguities or contradictions.
2. Record the current commit as the review base.
3. Dispatch `references/spec-page-implementer.md`, injecting the brief,
   wiki paths, shared binding rules, check command, and report path.
4. Generate a diff package from the recorded base.
5. Dispatch `references/spec-page-reviewer.md` against the brief, report,
   diff, binding rules, and check command.
6. Send all Critical and Important findings through one fix cycle, then
   review again. Defer Minors to final triage.
7. Append outcome, commits, findings, and spec conflicts to
   `.generate-wiki/progress.md`.

Reject code-derived architectural claims: this skill documents intent.
Specification claims require an exact tracked path and named section.
Untracked sources may be described but never linked as durable references.

Every generated page must:

- Populate Specification Sources with confirmed paths and sections.
- Populate Implementation Sources with exactly:
  `Implementation has not been assessed.`
- Populate Spec Deviations with exactly:
  `Implementation has not been assessed.`

Crash recovery skips ledger-complete pages. Resume an uncommitted page at
its check and review stage instead of regenerating it.

## S5: Cross-link and consistency pass

Dispatch the shared cross-linker once after all pages pass factual review.
Then directly rerun the full checker and a fresh bidirectional link scan.
Verify terminology against the specs and ensure implementation claims have
not appeared. Commit this pass once.

## S6: Final review

Build the whole-branch diff and triage files. Dispatch the shared final
reviewer on the most capable available model. Its spec-first attention lens
must verify:

- Each substantive claim maps to a confirmed specification source.
- Contradictory requirements remain explicit findings.
- Specification-declared system relationships agree across pages.
- Both not-yet-assessed markers remain exact.

Apply one fix cycle for the complete findings list, then rerun every
mechanical and link gate.

## S7: Handoff

Report pages created, review outcomes, ambiguous or contradictory
specifications, missing rationale, and other project findings. State clearly
that implementation has not been assessed. Offer to push and open a PR, but
do neither without explicit confirmation.

## SR1: Specification drift detection

Require a clean or user-approved working tree. Refresh the current branch;
do not create a new branch.

For each canonical page, or the `--pages` subset:

1. Parse only the Specification Sources subsection.
2. Let `LAST` be the most recent commit touching the page.
3. Run `git log --oneline $LAST.. -- <spec anchors>`.
4. Classify missing paths as hard drift.
5. Classify unparseable anchors as unrefreshable; never guess.

Implementation Sources are not inputs to spec refresh.

## SR2: Report and dry-run stop

Print page, changed spec commits, hard-drift anchors, and unrefreshable
notes. With `--dry-run`, stop before any file, branch, index, or commit
change.

## SR3: Update affected pages

Skip unchanged pages. For each drifted page, use the S4 implementer and
reviewer loop with a refresh brief containing only the changed specification
evidence. Update only claims affected by that evidence. Preserve exact
not-yet-assessed Implementation Sources and Spec Deviations markers. Make
one commit per refreshed page. Rerun cross-link verification only when links
changed.

## Error handling

- Missing PR tooling is irrelevant to spec facts; design rationale comes
  from confirmed specifications and tracked design records.
- A missing source blocks only the affected claim.
- A contradiction is reported and preserved, never silently resolved.
- Failed checks trigger the single fix cycle.
- Completed ledger entries are never regenerated.
