# Binding Rules

These rules are non-negotiable for every wiki page dispatch — implementer, reviewer,
fixer, or cross-linker. Paste this file's contents verbatim into each subagent's
prompt; do not summarize or paraphrase it away.

## 1. Anti-fabrication

**Anti-fabrication (absolute):** every sentence of decision rationale must be
traceable to the cited PR body, commit message, diff, or design doc. Never invent,
embellish, or infer rationale. When no source records a rationale, write:
`No PR or design doc records a rationale; observed current state: ...` — this is
the mandated fallback, not a failure.

If you catch yourself writing a plausible-sounding "because" that you cannot point
to a specific PR, commit, or doc for, stop and use the fallback instead.

## 2. Sourcing priority

Gather rationale in this order, degrading gracefully when a tier is unavailable:

1. Design docs the user identified during intake (the project-context interview
   run by the orchestrator — the agent that dispatched this task — before
   generation starts) — mine these for rationale.
   Link to them only if they are tracked in the repo; otherwise refer to them in
   prose as "the X design doc (untracked)" without a link.
2. PR bodies, via `gh pr view N --json title,body`, when `gh` is authenticated.
3. Commit messages and `git log` archaeology (`git log -p`, `git blame`) when
   no PR is available or `gh` is unauthenticated.
4. The anti-fabrication fallback phrasing (Section 1), when none of the above
   yields a rationale.

Every reference cited as a source must be durable: a PR number, a commit SHA, or
a path to a tracked file. Never cite a branch name, a local path outside the
repo, or an untracked file as a Ref.

## 3. Page conventions

- Use the 8 template sections, in this exact order, with none added or dropped:
  Purpose, Position in the System, Architecture, Runtime Flows, Key Decisions,
  Implementation Notes, Source Anchors, Related Pages.
- Diagrams are Mermaid only — no ASCII art, no embedded images.
- Never cite line numbers (e.g. `foo.rs:123`); reference function, type, and
  file names instead. Line numbers drift the moment code changes; names are
  what the check script (the repo's materialized `check-wiki.sh`) and
  future readers can verify.
- Links target only canonical wiki page filenames (the pages listed in the
  hub/README), never raw paths into `docs/` or other untracked locations.
- Before writing a sentence that names a symbol (function, type, module, file),
  verify it exists in the current source. Do not describe code you have not
  opened in this pass.
- Known debt and future work belong only under Implementation Notes, and must
  be explicitly labeled as debt/follow-up — never presented as current design.
- Target 150–350 lines per page; if a draft exceeds ~400 lines it is over-scoped.
  Split it or cut detail rather than let it run long.
- Write prose for engineers who already know the codebase's language and
  domain. No marketing tone, no tutorial hand-holding.

## 4. Honesty about gaps

Unwired code, dead code, stale comments, and spec drift discovered while
verifying a page against source must be documented on the page itself, under
Implementation Notes, and also called out in the subagent's return summary so
the orchestrator can include them in the run report. Never smooth these over or
omit them to make the page read cleaner — a page that hides a known gap is
worse than one that names it.

## 5. Audience

Write for developers of the target project — people who will read or modify
its code. Do not include consumer-facing tutorial content (install steps,
end-user walkthroughs), and do not duplicate material already covered by the
project's existing consumer-facing docs (README, user guides). If such docs
exist and are relevant, link to them instead of restating them.
