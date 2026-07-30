#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TEMPLATE="$ROOT/shared/assets/TEMPLATE.md"
CHECKER="$ROOT/shared/assets/check-wiki.sh.tmpl"
BINDINGS="$ROOT/shared/references/binding-rules.md"

expected=$(mktemp)
actual=$(mktemp)
trap 'rm -f "$expected" "$actual"' EXIT

printf '%s\n' \
  '## Purpose' \
  '## Position in the System' \
  '## Architecture' \
  '## Runtime Flows' \
  '## Key Decisions' \
  '## Implementation Notes' \
  '## Spec Deviations' \
  '## Source Anchors' \
  '## Related Pages' > "$expected"
grep '^## ' "$TEMPLATE" > "$actual"
cmp "$expected" "$actual"

grep -Fq '"## Spec Deviations"' "$CHECKER"
grep -Fq '### Specification Sources' "$TEMPLATE"
grep -Fq '### Implementation Sources' "$TEMPLATE"
grep -Fq 'No rationale found in available project history.' "$BINDINGS"
grep -Fq '`active`' "$BINDINGS"
grep -Fq '`resolved`' "$BINDINGS"
grep -Fq '`superseded`' "$BINDINGS"

test ! -e "$ROOT/assets/TEMPLATE.md"
test ! -e "$ROOT/references/binding-rules.md"
echo "test-contract: PASS"
