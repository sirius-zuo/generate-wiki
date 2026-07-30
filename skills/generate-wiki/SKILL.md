---
name: generate-wiki
description: Thin entry point that selects spec-to-wiki before implementation or code-to-wiki once substantive code exists, asking when project phase is ambiguous.
argument-hint: '[--from-spec|--from-code] [producer arguments]'
allowed-tools: Agent, Bash, Read, Grep, Glob, AskUserQuestion
---

# Generate Wiki Router

Select one installed producer skill and delegate the complete request. This
router is read-only: it does not create branches, scaffold files, write wiki
content, dispatch page workers, review pages, or commit changes.

## 1. Parse explicit overrides

Read `$ARGUMENTS`.

- If both `--from-spec` and `--from-code` appear, stop and ask the user to
  choose one. Do not inspect or delegate.
- `--from-spec` selects `spec-to-wiki`.
- `--from-code` selects `code-to-wiki`.
- Remove the selected override before delegation.
- Pass every remaining argument unchanged to the selected skill.

An explicit override takes precedence over repository inspection.

## 2. Detect substantive implementation

When no override exists, inspect the repository read-only:

1. Locate workspace and package manifests.
2. Locate conventional source roots for the detected ecosystems.
3. Sample modules beneath those roots.
4. Decide whether they contain nontrivial executable behavior.

The following do not establish substantive implementation by themselves:

- Documentation or specifications.
- Build, formatter, deployment, or editor configuration.
- generated stubs.
- Empty packages or placeholder modules.
- Data declarations without behavior.
- interface-only scaffolding.
- A prototype whose files do not implement a coherent runtime path.

Substantive implementation means nontrivial executable modules that together
implement at least one coherent project behavior or runtime path. Do not use
file extensions or the mere existence of `src/` as the decision.

## 3. Select or ask once

- Clear absence of substantive implementation selects `spec-to-wiki`.
- Clear presence selects `code-to-wiki`.
- Mixed prototypes, conflicting signals, or uncertainty are ambiguous.

For ambiguity, Ask exactly one user question: whether to document intended
architecture from specifications or implemented architecture from code.
Use the answer to select the producer. Do not ask follow-up questions; the
producer owns its own intake.

## 4. Delegate

Invoke the selected installed skill through the runtime's skill invocation
mechanism:

- `spec-to-wiki` for specification-first work.
- `code-to-wiki` for code creation, reconciliation, and refresh.

Pass every remaining argument unchanged, including `refresh`, `--dry-run`,
`--pages`, `--dir`, and producer-specific arguments. The selected producer
owns preflight, questions, branch behavior, page generation, checks, reviews,
commits, recovery, and handoff.

If the selected producer is not installed, stop and tell the user to run this
repository's installer. Do not fall back to implementing producer behavior
inside the router.
