# Spec and Code Wiki Skills Design

## Summary

Split the existing `generate-wiki` behavior into two focused producer
skills and retain `generate-wiki` as a thin router:

- `spec-to-wiki` creates and updates an architecture wiki from
  specifications before substantive implementation exists.
- `code-to-wiki` creates a wiki from a codebase or reconciles an existing
  spec-created wiki with implemented behavior.
- `generate-wiki` detects the project phase and delegates to the
  appropriate producer. It asks the user when the evidence is ambiguous.

All three skills live in one repository and use a single canonical shared
source for the page contract, assets, sourcing rules, and reusable review
prompts. An installer materializes self-contained installed skills from
that source. Raw copying of source skill directories is no longer a
supported installation method.

## Goals

- Preserve the existing `generate-wiki` entry point and refresh interface.
- Let teams create the architecture wiki before a codebase exists.
- Evolve the same pages from intended architecture to implementation truth.
- Preserve specification provenance after code-based reconciliation.
- Explain material deviations from specifications without inventing
  rationale.
- Maintain only one source copy of shared contracts and resources.
- Allow either producer skill to be installed independently as a
  self-contained skill.

## Non-goals

- Maintaining separate specification and implementation wikis.
- Treating harmless prose differences as implementation deviations.
- Inferring undocumented reasons for deviations.
- Making the router a second implementation of either producer workflow.
- Supporting installation by directly copying a source skill directory.

## Repository Architecture

The repository will use this source layout:

```text
generate-wiki/
├── skills/
│   ├── generate-wiki/
│   │   └── SKILL.md
│   ├── spec-to-wiki/
│   │   ├── SKILL.md
│   │   └── references/
│   └── code-to-wiki/
│       ├── SKILL.md
│       └── references/
├── shared/
│   ├── assets/
│   └── references/
├── scripts/
│   └── install.sh
└── tests/
```

`shared/` is the only maintained source for:

- The wiki page and hub contracts.
- Page and hub templates.
- The mechanical wiki checker.
- Common sourcing and anti-fabrication rules.
- Reusable implementer, reviewer, cross-linker, and final-review behavior.

Each specialized skill owns only its workflow and specialized prompts.
The router owns only phase detection, explicit overrides, and delegation.

## Skill Responsibilities

### `generate-wiki`

The router performs read-only phase detection before delegation. It looks
for substantive implementation using project manifests, conventional
source roots, and nontrivial executable modules. Documentation,
configuration, generated stubs, empty packages, and interface-only
scaffolding do not by themselves establish that implementation exists.

The router:

- Delegates to `spec-to-wiki` when substantive implementation is clearly
  absent.
- Delegates to `code-to-wiki` when substantive implementation is clearly
  present.
- Asks one user question when prototypes or mixed evidence make the
  result ambiguous.
- Accepts explicit `--from-spec` and `--from-code` overrides.
- Passes all remaining arguments through to the selected producer.
- Routes the backward-compatible `generate-wiki refresh ...` invocation
  to `code-to-wiki refresh ...` when implementation exists.
- May route a refresh to `spec-to-wiki` when no implementation exists and
  the wiki is still spec-only.

It does not scaffold, write, review, or refresh wiki pages itself.

### `spec-to-wiki`

`spec-to-wiki` operates before substantive implementation exists. It:

1. Requires a git repository and confirms a clean or user-approved dirty
   working tree.
2. Discovers likely specification locations such as `docs/`, `specs/`,
   `design/`, `adr/`, and `rfcs/`.
3. Accepts explicit specification file and directory arguments.
4. Proposes authoritative inputs and a subsystem page set, then confirms
   them in one interview round.
5. Scaffolds the common wiki contract.
6. Generates and fact-checks pages sequentially against the confirmed
   specifications.
7. Cross-links and validates the complete wiki.
8. Reports ambiguous or contradictory specifications as project
   findings.

If rerun before implementation exists, it detects changes through
specification anchors and updates only affected pages.

### `code-to-wiki`

`code-to-wiki` supports two paths:

- **Create:** when no wiki exists, generate a code-grounded wiki using the
  current generation pipeline and available project history.
- **Reconcile:** when a wiki exists, update it to implementation truth
  while preserving specification intent and documenting deviations.

The existing refresh interface and R1-R3 behavior move to this skill:

```text
code-to-wiki refresh
code-to-wiki refresh --dry-run
code-to-wiki refresh --pages a,b
```

Refresh retains anchor-based drift detection, report-only dry runs,
one commit per refreshed page, current-branch updates, historical decision
preservation, sequential page processing, and degraded operation when PR
tooling is unavailable.

Reconciliation adds a spec-versus-code comparison to affected pages. This
is additive to existing code-anchor drift detection and does not replace
it.

## Shared Page Contract

Every page has the same ordered sections:

1. Purpose
2. Position in the System
3. Architecture
4. Runtime Flows
5. Key Decisions
6. Implementation Notes
7. Spec Deviations
8. Source Anchors
9. Related Pages

`Source Anchors` distinguishes specification sources from implementation
sources. This preserves both provenance chains during the transition from
planned to implemented architecture.

### Spec-created page state

A page produced by `spec-to-wiki`:

- Describes intended behavior in the main sections.
- Records confirmed specification files and precise sections as
  specification anchors.
- Uses standardized wording to state that implementation anchors are not
  yet available.
- States that implementation deviations have not yet been assessed.

### Reconciled page state

When `code-to-wiki` reconciles a spec-created page, it:

- Rewrites the main sections to describe actual implementation.
- Preserves specification anchors.
- Adds implementation anchors.
- Compares material, testable specification claims with implementation
  evidence.
- Records differences that affect architecture, behavior, constraints,
  interfaces, or explicitly stated decisions.
- Ignores harmless wording differences.

For a codebase without a prior specification wiki, `code-to-wiki`
generates the same schema, records specification provenance as
unavailable, and does not manufacture deviations.

## Spec Deviation Records

Each material deviation records:

- **Expected:** the specification claim and its source.
- **Implemented:** observed behavior and implementation anchors.
- **Reason:** evidence from design records, pull requests, or commits.
- **Impact:** the practical consequence.
- **Status:** `active`, `resolved`, or `superseded`.

The skill never invents a reason. When available history does not explain
the difference, it records:

> No rationale found in available project history.

It also surfaces the missing rationale in the final project findings.
Deviation records preserve history. Later runs may update status and
append resolution evidence, but must not erase the original expected and
implemented account.

## Data Flow

### Spec-first lifecycle

```text
confirmed specs
  -> spec-to-wiki
  -> intended architecture pages
  -> implementation appears
  -> code-to-wiki reconciliation
  -> implementation-truth pages plus deviation history
  -> code-to-wiki refresh
```

### Router flow

```text
generate-wiki
  -> explicit override? use it
  -> otherwise inspect implementation evidence
  -> absent: spec-to-wiki
  -> present: code-to-wiki
  -> ambiguous: ask once, then delegate
```

The selected producer remains responsible for its own preflight,
interview, branch behavior, ledger, page loop, review gates, and handoff.

## Installation and Packaging

A dependency manifest declares the shared resources required by each
skill. The installer resolves the manifest and materializes a
self-contained installed directory containing the specialized skill and
copies of its required shared resources.

The installer supports:

- Installing either producer and its required shared resources.
- Installing `generate-wiki`, both producer skills, and all required
  shared resources as one operation.
- User-level and project-level destinations.
- A dry run that lists every file that would be copied or replaced.
- Idempotent reinstallation when installed files match a previous
  generated package.
- Refusal to overwrite locally modified installed files without explicit
  confirmation.

Materialized shared files are generated installation artifacts. They are
marked with their canonical source and repository revision and are not
maintained manually. The repository itself contains only one canonical
copy.

## Error Handling and Recovery

- A dirty working tree requires user confirmation before producer edits.
- Ambiguous router detection asks the user rather than guessing.
- Missing or unauthenticated PR tooling degrades sourcing to design
  documents and commit history.
- Missing rationale is recorded explicitly and reported as a finding.
- Ambiguous source evidence blocks the affected claim, not the entire run.
- Crash-recovery ledgers preserve completed page work and resume
  uncommitted drafts at the review/check stage.
- Unparseable anchors are reported as unrefreshable and are not guessed.
- Installer dry runs never modify the destination.
- Installer conflicts stop before overwriting locally modified files
  unless the user explicitly confirms.

## Validation Strategy

### Source checks

- Every manifest resource exists.
- No common resource is duplicated in specialized source directories.
- Specialized prompts reference only declared shared dependencies.

### Packaging checks

Each installation variant is materialized in a temporary directory. Tests
verify its complete file set, internal references, executable modes, and
absence of unresolved source-layout paths.

### Contract checks

Both producers must generate pages satisfying the same nine-section
schema, deviation format, anchor categories, and link rules.

### Workflow scenarios

Manual or automated scenarios cover:

- Spec-only wiki creation.
- Spec-only incremental refresh.
- Code-only wiki creation.
- Spec-to-code reconciliation.
- Explained and unexplained deviations.
- Resolved and superseded deviation history.
- Unchanged `code-to-wiki refresh` behavior.
- Backward-compatible `generate-wiki refresh` delegation.
- Ambiguous router detection and explicit overrides.
- Dry-run safety.
- Degraded PR tooling.
- Crash recovery.
- Independent producer installation.
- Router installation with both delegated skills.
- Protection of locally modified installed files.

## Documentation and Compatibility

The README will:

- Introduce the spec-first and code-first lifecycles.
- Explain when to invoke each specialized skill.
- Retain `generate-wiki` as the recommended convenience entry point.
- Document the existing refresh arguments.
- Explain deviation semantics and missing-rationale behavior.
- Replace raw-copy installation instructions with installer usage.

Existing `generate-wiki` users retain the familiar command name and
refresh arguments. The behavioral change is architectural: the entry
point delegates instead of implementing generation and refresh itself.

## Success Criteria

- There is one maintained source copy of every shared resource.
- Installing one producer creates a complete, independently runnable
  skill.
- Installing the router also installs both producer skills.
- Spec-created pages can be reconciled in place without losing
  specification provenance.
- Main page prose reflects actual implementation after reconciliation.
- Every material spec difference is recorded or explicitly reported as
  lacking evidence.
- Existing `generate-wiki refresh` use cases retain their interface and
  core behavior.
- Packaging and workflow validation catch missing shared resources,
  schema drift, unsafe overwrites, and refresh regressions.
