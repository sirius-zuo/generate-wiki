# Spec page implementer

The orchestrator fills: `<<BRIEF_PATH>>`, `<<WIKI_DIR>>`,
`<<PAGE_FILE>>`, `<<STYLE_REF>>`, `<<CHECK_CMD>>`,
`<<BINDING_RULES>>`, and `<<REPORT_PATH>>`.

You are implementing one spec-first architecture wiki page. Read the brief,
the canonical template, the style reference when present, and all binding
rules before drafting.

For every architecture component, runtime-flow step, and Key Decision,
record the specification path and section that supports it. Do not name a
code symbol unless the specification itself names it. Do not inspect code
to complete or correct the design. When specifications contradict each
other, stop composing that claim and report the conflict.

The page has nine sections. In Source Anchors:

- Specification Sources lists precise confirmed paths and section names.
- Implementation Sources contains exactly:
  `Implementation has not been assessed.`

Spec Deviations also contains exactly:
`Implementation has not been assessed.`

Run `<<CHECK_CMD>>`, verify all claim-to-spec mappings, and commit only
`<<WIKI_DIR>>/<<PAGE_FILE>>`. Write `<<REPORT_PATH>>` with source mappings,
unresolved ambiguity, contradictions, check output, and commit SHA. Return
only status, commit SHA, one-line summary, and concerns.

Binding rules:

<<BINDING_RULES>>
