#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SKILL="$ROOT/skills/spec-to-wiki/SKILL.md"
IMPLEMENTER="$ROOT/skills/spec-to-wiki/references/spec-page-implementer.md"
REVIEWER="$ROOT/skills/spec-to-wiki/references/spec-page-reviewer.md"

grep -Fq 'name: spec-to-wiki' "$SKILL"
grep -Fq -- '--spec <path>' "$SKILL"
grep -Fq 'docs/`, `specs/`, `design/`, `adr/`, and `rfcs/' "$SKILL"
grep -Fq 'substantive implementation' "$SKILL"
grep -Fq 'Specification Sources' "$IMPLEMENTER"
grep -Fq 'Implementation Sources' "$IMPLEMENTER"
grep -Fq 'Implementation has not been assessed.' "$IMPLEMENTER"
grep -Fq 'contradict' "$REVIEWER"
grep -Fq 'refresh --dry-run' "$SKILL"
echo "test-spec-skill: PASS"
