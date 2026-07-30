# Wiki Skills: Test Scenarios & Evidence

Manual verification scenarios. There is no automation; invoke the skill against the described input and compare against expected output.

## TS-1: Generate, full pipeline

**Input:** A small multi-module repo (3–4 subsystems, one directory/package
per subsystem) with real merged-PR history and `gh` authenticated.

**Invocation:** `/code-to-wiki`, run from the repo root. In the interview,
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
- Immediately after, `/code-to-wiki refresh --dry-run` reports zero drifted
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

**Invocation:** `/code-to-wiki`. In the interview, confirm there are no
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

**Invocation:** `/code-to-wiki refresh`

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

**Invocation:** `/code-to-wiki refresh --dry-run`

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

**Invocation:** `/code-to-wiki`

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

## TS-6: Spec-only creation

**Input:** A git repository containing confirmed architecture specifications
under `specs/`, with no substantive implementation.

**Invocation:** `/spec-to-wiki --spec specs/`

**Expected output:**
- The proposed page set is derived from the confirmed specs.
- Every substantive claim cites a specification path and section.
- Every page's Implementation Sources and Spec Deviations sections say
  exactly `Implementation has not been assessed.`
- Ambiguous or contradictory requirements appear in the final findings.

**Fail signals:**
- A page fills a gap by inspecting code, a stub, or general plausibility.
- A contradiction is silently resolved.
- A page claims that implementation was verified.

## TS-7: Spec-only incremental refresh

**Input:** The TS-6 repository after one commit changes a specification
anchor used by exactly one page.

**Invocation:** `/spec-to-wiki refresh`

**Expected output:**
- The drift report names exactly one page and the specification commit.
- Exactly that page receives one commit.
- Implementation and deviation markers remain unchanged.

**Fail signals:**
- Implementation Sources participates in spec drift detection.
- An unaffected page changes.
- Refresh creates a branch.

## TS-8: Spec-to-code reconciliation

**Input:** A TS-6 wiki plus substantive implementation that materially
differs from one explicit interface constraint. A commit message explains
the reason.

**Invocation:** `/code-to-wiki`

**Expected output:**
- Main architecture and runtime-flow prose reflects the code.
- Specification Sources remains intact and Implementation Sources is added.
- Spec Deviations records Expected, Implemented, evidenced Reason, Impact,
  and `active` Status.

**Fail signals:**
- Main prose continues to present spec intent as current behavior.
- Specification provenance is erased.
- A wording-only difference becomes a deviation.

## TS-9: Unexplained deviation

**Input:** The TS-8 repository with a material deviation that has no
supporting design record, PR body, or commit message.

**Invocation:** `/code-to-wiki`

**Expected output:**
- Reason is exactly `No rationale found in available project history.`
- The missing rationale appears as a first-class final finding.

**Fail signals:**
- The skill infers a plausible reason from code shape.
- The deviation or missing-rationale finding is omitted.

## TS-10: Router ambiguity and overrides

**Input:** A repository with complete specs and a partial prototype that does
not implement a coherent runtime path.

**Invocation:** Run `/generate-wiki`, then separately run
`/generate-wiki --from-spec` and `/generate-wiki --from-code`.

**Expected output:**
- The unqualified invocation asks exactly one project-phase question.
- Each override delegates immediately to its named producer.
- Remaining arguments are forwarded unchanged.

**Fail signals:**
- The router writes files or creates a branch.
- It treats the mere presence of `src/` as substantive implementation.
- It asks producer intake questions itself.

## TS-11: Producer-only installation

**Input:** An empty temporary skills destination.

**Invocation:**
`./scripts/install.sh --skill spec-to-wiki --dest <destination>`

**Expected output:**
- Only `spec-to-wiki` is installed.
- Its specialized prompts and every declared shared file are present.
- Installed paths referenced by SKILL.md resolve locally.

**Fail signals:**
- Another producer is installed.
- The installed skill depends on the source checkout.

## TS-12: Router bundle installation

**Input:** An empty temporary skills destination.

**Invocation:**
`./scripts/install.sh --skill generate-wiki --dest <destination>`

**Expected output:** `generate-wiki`, `spec-to-wiki`, and `code-to-wiki`
are complete and self-contained.

**Fail signals:** Delegation targets or shared resources are missing.

## TS-13: Installer safety

**Input:** An installed producer whose installed SKILL.md has a local edit.

**Invocation:** Run reinstall normally, with `--dry-run`, and finally with
`--force`.

**Expected output:**
- Normal reinstall refuses before overwriting.
- Dry-run lists changes and touches nothing.
- `--force` replaces the modified installed file.

**Fail signals:**
- A normal reinstall partially updates the destination before refusing.
- Dry-run creates the destination or modifies a file.
