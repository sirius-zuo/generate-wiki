# generate-wiki: Test Scenarios & Evidence

Manual verification scenarios. There is no automation; invoke the skill against the described input and compare against expected output.

## TS-1: Generate, full pipeline

**Input:** A small multi-module repo (3–4 subsystems, one directory/package
per subsystem) with real merged-PR history and `gh` authenticated.

**Invocation:** `/generate-wiki`, run from the repo root. In the interview,
approve the auto-derived page set and the default `wiki` directory / branch
name.

**Expected output:**
- A new branch `docs/internal-wiki` exists.
- One scaffold commit exists, containing `wiki/README.md`, `wiki/TEMPLATE.md`,
  and `scripts/check-wiki.sh`.
- Exactly one commit per approved page.
- One cross-link commit and (if the final reviewer found anything) one
  final-review fix commit.
- `scripts/check-wiki.sh` (no arguments) exits 0.
- Immediately after, `/generate-wiki refresh --dry-run` reports zero drifted
  pages.

**Fail signals:**
- Any Key Decision entry whose Ref, when opened, does not contain the claim
  attributed to it (fabricated rationale).
- A page missing one of the 8 template sections (Purpose, Position in the
  System, Architecture, Runtime Flows, Key Decisions, Implementation Notes,
  Source Anchors, Related Pages).
- A link from page A to page B with no corresponding link back (asymmetric
  link).

## TS-2: Fabrication resistance

**Input:** A repo with commit history but no PRs (no `gh` remote, or a repo
with zero merged PRs) and no design-doc directories (`docs/`, `doc/`,
`design/`, `adr/`, `rfcs/` all absent).

**Invocation:** `/generate-wiki`. In the interview, confirm there are no
design docs to mine.

**Expected output:** Every Key Decision entry's Ref is a commit SHA, or the
entry reads exactly:
`No PR or design doc records a rationale; observed current state: ...`
Running `grep -rEn "because|chosen to" wiki/*.md` (excluding
`TEMPLATE.md`/`README.md`) returns only sentences whose wording traces back
to text present in a commit message.

**Fail signals:**
- Any decision entry with causal rationale ("because...", "chosen to...")
  that is not traceable to a commit message.
- Any Ref that is a branch name, a local path outside the repo, or an
  untracked file.

## TS-3: Refresh detects drift

**Input:** The TS-1 repo immediately after generation, then one new commit
that renames a function or path listed in exactly one page's Source
Anchors.

**Invocation:** `/generate-wiki refresh`

**Expected output:** The run's drift table names exactly the one page whose
anchors the seeded commit touched. That page receives exactly one new
commit reflecting the change: either a new Key Decision entry, added
above the existing ones (the prior entries are still present, byte-for-byte,
below it; decision history appended, never rewritten), or amended prose in
an affected section, whichever the change warrants. Its Source Anchors are
updated only if the seeded commit renamed or moved an anchored path. No
other page file changes.

**Fail signals:**
- A page other than the seeded one is modified or recommitted.
- An existing Key Decision entry is edited, reworded, or removed rather than
  a new entry being added.

## TS-4: Dry-run audit

**Input:** A fresh copy of the TS-1 repo with the same seeded drift commit
from TS-3 applied, before running any refresh.

**Invocation:** `/generate-wiki refresh --dry-run`

**Expected output:** The printed drift table is identical to the one
produced in TS-3 (same page, same drifting commit subject). `git status`
is clean afterward: no files staged, modified, or committed, and no branch
created.

**Fail signals:**
- Any file is modified, staged, or committed.
- The drift table differs from TS-3's (different page named, or missing
  the drifting commit).

## TS-5: Degraded environment

**Input:** The TS-1 repo, with `gh auth logout` run first (or `gh`
uninstalled) so `gh` is unauthenticated for the whole run.

**Invocation:** `/generate-wiki`

**Expected output:** The run completes through final handoff without
stopping on a `gh` error. Every Key Decision Ref is a commit SHA (never a
PR number). No raw `gh` error or auth-prompt text appears in any wiki page
or in the final summary shown to the user.

**Fail signals:**
- The run halts on a `gh` authentication error instead of degrading to
  commit archaeology.
- Any page cites a PR number as a Ref despite `gh` being unauthenticated
  for the entire run.
- Raw CLI error text leaks into a wiki page or the final summary.
