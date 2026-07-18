# Page implementer dispatch template

## For the orchestrator: how to fill this template

Substitute seven slots before sending this file as a subagent prompt:
`<<BRIEF_PATH>>` is the path to the page brief you composed for this page
(source table: directories/modules, design docs, PRs/commits, minimum
flows and decisions). `<<WIKI_DIR>>` is the target repo's wiki directory
(e.g. `wiki/`). `<<PAGE_FILE>>` is the page's filename inside
`<<WIKI_DIR>>` (e.g. `agent.md`). `<<STYLE_REF>>` is the filename of an
already-committed wiki page to match for tone and density, or the literal
string "none: you are writing the first page" if none exists yet.
`<<CHECK_CMD>>` is the exact command that runs the rendered check script
against this page. `<<BINDING_RULES>>` is the full contents of
`references/binding-rules.md`, pasted verbatim, unsummarized.
`<<REPORT_PATH>>` is the file this subagent must write its full report to.
Dispatch on a mid-tier model. Dispatch one page
at a time, never in parallel: each page's commit becomes the next
page's `git log` context, and parallel dispatch risks two pages
colliding on the same cross-link or terminology choice.

---

You are implementing one page of an internal architecture wiki, for an
audience of developers who work on this project's own code, not its
end users. Read `<<BRIEF_PATH>>` first; it is your requirements.

Before drafting, study two references:

- `<<WIKI_DIR>>/TEMPLATE.md` is the page structure you must follow
  exactly: 8 sections, in this order, none added and none dropped.
- `<<STYLE_REF>>` is an already-committed page to match for tone,
  density, and level of detail (or, if this is the first page, there is
  nothing to match yet).

The following binding rules apply to everything you write. They are
non-negotiable. Paste their full text below this line; do not
summarize or paraphrase:

<<BINDING_RULES>>

Follow this six-step procedure:

- **Step A (Explore):** read the sources named in the brief (module/package
  code, design docs, PRs via `gh pr view N --json title,body` when
  available, `git log --oneline -- <dirs>`). Confirm every type/function/
  file you plan to name exists in current source before writing it.
- **Step B (Draft):** copy the template structure; fill all eight sections.
  The brief's flows/decisions are a floor, not a ceiling; dig for more
  real decisions in the sources. Position-in-System links use canonical
  filenames only.
- **Step C (Verify refs):** every Key Decision Ref resolves (`gh pr view N`
  or `git show SHA`); every named symbol exists in source.
- **Step D (Check):** run `<<CHECK_CMD>>`; it must pass for your page.
- **Step E (Self-review):** template compliance; no aspirational content
  outside Implementation Notes; every rationale sentence traceable to its
  cited source; length within target.
- **Step F (Commit):** `git add <<WIKI_DIR>>/<<PAGE_FILE>> && git commit`
  with a one-line message naming the page. Commit ONLY your page file.

Report contract: write a full report to `<<REPORT_PATH>>` covering the
sections you wrote, the page's line count, every Key Decision with its
Ref and rationale source, the symbols you verified, the Step D check
output, your Step E self-review notes, and the commit SHA. Return to the orchestrator
ONLY: status (`DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` /
`BLOCKED`), the commit SHA, a one-line summary, and any concerns.
