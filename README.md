# Wiki Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![agent-skill](https://img.shields.io/badge/agent--skill-8A2BE2)
![architecture](https://img.shields.io/badge/architecture-blue)
![documentation](https://img.shields.io/badge/documentation-blue)
![wiki](https://img.shields.io/badge/wiki-blue)

Create an internal architecture wiki before implementation, then evolve the
same pages into an honest description of the codebase. This repository
contains three Agent Skills:

- `spec-to-wiki` creates or refreshes intended architecture from confirmed
  specifications when substantive implementation does not exist.
- `code-to-wiki` creates a wiki from code or reconciles a spec-created wiki
  with implemented behavior.
- `generate-wiki` is a thin convenience entry point. It detects the project
  phase, asks once when evidence is ambiguous, and delegates.

The lifecycle is:

```text
specs -> spec-to-wiki -> intended wiki
code  -> code-to-wiki -> implementation wiki + spec deviations
```

After reconciliation, the main architecture and flow sections describe actual
code. Specification intent remains traceable through separate source anchors,
and material differences appear under Spec Deviations. Reasons must come from
tracked design records, pull requests, or commits. When history has no answer,
the wiki says so instead of inventing one.

The skills follow the open [Agent Skills](https://agentskills.io) format and
require a runtime with subagent dispatch, file operations, and a user-question
mechanism.

## Install

Raw copying of source directories is not supported because producer skills
share one canonical resource tree. Use the installer to materialize
self-contained skills.

Install the phase-detecting entry point and both producers:

```bash
./scripts/install.sh --skill generate-wiki --dest ~/.claude/skills
```

Install one producer independently:

```bash
./scripts/install.sh --skill spec-to-wiki --dest ~/.claude/skills
./scripts/install.sh --skill code-to-wiki --dest ~/.claude/skills
```

Use a project skill directory instead of `~/.claude/skills` for
project-scoped installation. Add `--dry-run` to inspect every planned copy.
The installer refuses to replace locally modified installed files; use
`--force` only when that replacement is intentional.

## Usage

Recommended convenience entry point:

```text
/generate-wiki
/generate-wiki --from-spec --spec specs/architecture.md
/generate-wiki --from-code
/generate-wiki refresh --dry-run
/generate-wiki refresh --pages api,storage
```

Direct producer invocation:

```text
/spec-to-wiki --spec specs/
/spec-to-wiki refresh --dry-run
/code-to-wiki
/code-to-wiki refresh --dry-run
/code-to-wiki refresh --pages api,storage
```

`generate-wiki refresh ...` remains backward compatible: it forwards the
refresh arguments to the selected producer. Once substantive code exists, the
destination is `code-to-wiki`, whose R1-R3 anchor-based refresh behavior is
preserved.

## Shared Page Contract

Every subsystem page uses nine ordered sections:

1. Purpose
2. Position in the System
3. Architecture
4. Runtime Flows
5. Key Decisions
6. Implementation Notes
7. Spec Deviations
8. Source Anchors
9. Related Pages

Source Anchors separates Specification Sources from Implementation Sources.
A spec-first page marks implementation and deviations as not assessed.
`code-to-wiki` replaces main prose with implementation truth while retaining
the specification provenance.

Each material deviation records Expected, Implemented, Reason, Impact, and
Status (`active`, `resolved`, or `superseded`). Existing Expected and
Implemented accounts are historical records and are not erased by refresh.

## Repository Structure

Three layers keep responsibilities separate:

1. `skills/` contains the router and producer orchestration plus
   workflow-specific prompts.
2. `shared/` is the only maintained source for the page contract, assets,
   anti-fabrication rules, and reusable reviewer prompts.
3. `scripts/install.sh` reads each skill's manifest and materializes
   standalone installed skills.

Run source and packaging checks with:

```bash
bash tests/run-all.sh
```

Manual end-to-end scenarios are documented in [TESTS.md](TESTS.md).

## Origin

The original `generate-wiki` pipeline was extracted from the process used to
generate agentverse's internal architecture wiki (PR #31, merged 2026-07-07).

## License

MIT. See [LICENSE](LICENSE).
