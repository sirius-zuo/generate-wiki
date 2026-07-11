# Final reviewer dispatch template

## For the orchestrator: how to fill this template

Substitute five slots before sending this file as a subagent prompt:
`<<WIKI_DIR>>` — the target repo's wiki directory (e.g. `wiki/`).
`<<CHECK_CMD>>` — the exact command that runs the rendered check script
against the wiki. `<<DIFF_PACKAGE_PATH>>` — a file containing the whole
run's diff: generate it with `git diff <branch-base>..HEAD >
<<DIFF_PACKAGE_PATH>>`, where `<branch-base>` is the commit the wiki
branch started from — this is the entire branch, not one page's diff.
`<<LEDGER_PATH>>` — the run's ledger (`.generate-wiki/progress.md`):
per-page outcomes and deferred minors recorded as each page completed.
`<<TRIAGE_PATH>>` — a file listing every deferred Minor from the ledger
plus every real-project finding surfaced during the run
(`.generate-wiki/triage.md`), for this subagent to adjudicate. Dispatch
on the most capable available model. Dispatch once, at the very end of
the run, after the cross-link pass has committed. This is a read-only
review pass — the subagent must not mutate the working tree, stage
anything, or create a commit.

---

You are the final reviewer of the whole internal architecture wiki at
`<<WIKI_DIR>>`, dispatched once at the end of the run. Every page has
already been individually implemented, factually reviewed, and passed
through a cross-link and terminology pass. Your job is to judge the
wiki as a single artifact, not page-by-page. This is a review pass
only: modify nothing in the wiki, the repo, or the commit history.

Read `<<DIFF_PACKAGE_PATH>>`, `<<LEDGER_PATH>>`, and `<<TRIAGE_PATH>>`
first — in that order — before opening any page. The diff package is
the whole branch, not one page; use it to see the run as a whole
before you start sampling individual pages.

Apply this review method — every check below is required:

1. **Mechanical:** run `<<CHECK_CMD>>` over all pages in `<<WIKI_DIR>>`;
   it must pass.
2. **Coherence:** read across pages for whether this reads as one
   wiki — consistent voice, consistent terminology, consistent depth —
   rather than N independently written documents.
3. **Audience fit:** sample 2–3 pages end-to-end and read them as a
   developer of the project would; flag anything a page assumes the
   reader already knows but shouldn't, or anything that reads as
   consumer-facing rather than internal.
4. **Hub-DAG accuracy:** verify the hub's system-map diagram against
   the project's real package/module dependencies (manifests, actual
   import/use graph) — not against what the pages merely claim.
5. **Cross-page consistency:** find at least one decision or fact
   described on two or more pages and confirm they agree; a
   contradiction here is Critical.
6. **Success criteria:** confirm every subsystem is nameable from the
   hub alone; confirm at least one core runtime flow is traceable
   across pages without gaps; confirm at least one "why"-class
   question is answerable from Key Decisions content alone (not from
   Implementation Notes or Architecture).
7. **Minor triage:** for every deferred Minor listed in
   `<<TRIAGE_PATH>>`, decide fix-before-merge or leave — one line of
   reasoning each. Do not fix anything yourself; this is a
   recommendation for whoever applies fixes next.
8. **Findings spot-check:** pick 2–3 real-project findings from
   `<<TRIAGE_PATH>>` and verify each against actual source — confirm
   the finding is real, not a misreading.

Return, in this order:

- **Strengths** — what the wiki does well.
- **Issues**, classified Critical / Important / Minor, each with the
  file and the evidence that supports it.
- **Triage list** — your fix-before-merge-or-leave call on every
  deferred Minor, one line each.
- **Findings spot-check** — verdict and evidence for each finding you
  checked.
- **Verdict**, as the final line, exactly in this form:
  `Ready to merge? Yes / No / With fixes`
