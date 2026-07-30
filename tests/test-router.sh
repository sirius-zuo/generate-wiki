#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SKILL="$ROOT/skills/generate-wiki/SKILL.md"

grep -Fq 'name: generate-wiki' "$SKILL"
grep -Fq -- '--from-spec' "$SKILL"
grep -Fq -- '--from-code' "$SKILL"
grep -Fq 'substantive implementation' "$SKILL"
grep -Fq 'generated stubs' "$SKILL"
grep -Fq 'interface-only scaffolding' "$SKILL"
grep -Fq 'Ask exactly one' "$SKILL"
grep -Fq 'spec-to-wiki' "$SKILL"
grep -Fq 'code-to-wiki' "$SKILL"
grep -Fq 'Pass every remaining argument unchanged' "$SKILL"
if grep -Eq 'Generate G[1-7]|Refresh R[1-3]|Scaffold' "$SKILL"; then
  echo "router contains producer workflow" >&2
  exit 1
fi
echo "test-router: PASS"
