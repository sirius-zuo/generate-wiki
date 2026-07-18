# Cross-linker dispatch template

## For the orchestrator: how to fill this template

Substitute four slots before sending this file as a subagent prompt:
`<<WIKI_DIR>>` is the target repo's wiki directory (e.g. `wiki/`).
`<<CHECK_CMD>>` is the exact command that runs the rendered check script
against the wiki. `<<BINDING_RULES>>` is the full contents of
`references/binding-rules.md`, pasted verbatim, unsummarized.
`<<REPORT_PATH>>` is the file this subagent must write its full report
to. Dispatch on a mid-tier model. Dispatch
once, after every page has been individually implemented and reviewed,
never mid-run: the link graph and hub index are only meaningful once
all pages exist.

---

You are running the cross-link and terminology pass over the whole
wiki at `<<WIKI_DIR>>`. Every page already exists and has passed its
own factual review; your job is wiki-wide consistency, not page
content. Read every page in `<<WIKI_DIR>>` before making any edit.

The following binding rules apply to everything you write. They are
non-negotiable. Paste their full text below this line; do not
summarize or paraphrase:

<<BINDING_RULES>>

Follow this four-step procedure:

**Step A (Build the link graph and verify bidirectionality):**

Build the full link graph: for each page, extract every relative `.md`
link anywhere in the page; verify **bidirectionality**: if page A links
page B anywhere (prose, Position in the System, or Related Pages), page
B's Related Pages must link back to A. Fix asymmetries by ADDING a line to
the deficient page's Related Pages; never delete or rewrite existing
content. Scan with a script, not by eye; asymmetric-edge lists built
manually have missed 80% of edges in practice.

- **Step B (Terminology sweep):** find every concept given more than
  one name across pages (e.g. a type referred to as both "the request
  builder" and "the builder"), and settle on one name per concept.
  Make the minimal edit at each site: retitle references, do not
  rewrite surrounding prose.
- **Step C (Hub-index finalization):** rewrite each page's one-liner in
  the hub's Page Index from that page's actual, as-committed Purpose
  section, not from the provisional summary written during scaffolding.
- **Step D (Check and prove symmetry):** run `<<CHECK_CMD>>` over every
  page; it must pass. Then re-run your link-graph scan fresh (not
  reusing Step A's output) and confirm zero asymmetric edges remain.

Scope discipline: your edits are link, terminology, and index changes
only. Do not restructure sections, do not touch any accuracy claim a
page reviewer already approved, and do not add new rationale. Any new
sentence you introduce (a retitled reference, a rewritten Related Pages
line) must still be source-verified per the binding rules above: if it
names a symbol or claim, confirm it exists before writing it.

Finish by running `<<CHECK_CMD>>` over all pages one last time and
committing everything in a single commit (`git add <<WIKI_DIR>> && git
commit` with a message describing the cross-link and terminology pass).

Report contract: write a full report to `<<REPORT_PATH>>` covering
every asymmetric edge you found and fixed (page pairs, before/after),
every terminology change (old name → new name, sites touched), the
hub-index one-liners you rewrote, the final `<<CHECK_CMD>>` output, and
your fresh symmetric-scan proof. Return to the orchestrator ONLY:
status (`DONE` / `DONE_WITH_CONCERNS` / `BLOCKED`), the commit SHA, a
one-line summary, and any concerns.
