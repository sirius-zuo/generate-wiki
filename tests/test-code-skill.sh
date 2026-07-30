#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OLD="$ROOT/SKILL.md"
NEW="$ROOT/skills/code-to-wiki/SKILL.md"
DEVIATIONS="$ROOT/skills/code-to-wiki/references/deviation-reviewer.md"

test ! -e "$OLD"
grep -Fq 'name: code-to-wiki' "$NEW"
grep -Fq 'refresh [--dry-run] [--pages a,b]' "$NEW"
grep -Fq 'Refresh R1: Drift detection' "$NEW"
grep -Fq 'Refresh R2: Report / dry-run stop' "$NEW"
grep -Fq 'Refresh R3: Update loop' "$NEW"
grep -Fq 'One commit per refreshed page.' "$NEW"
grep -Fq 'NEVER rewrite or delete an existing decision entry' "$NEW"
grep -Fq 'No rationale found in available project history.' "$NEW"
grep -Fq 'Expected' "$DEVIATIONS"
grep -Fq 'Implemented' "$DEVIATIONS"
grep -Fq 'Reason' "$DEVIATIONS"
grep -Fq 'Impact' "$DEVIATIONS"
grep -Fq 'Status' "$DEVIATIONS"
echo "test-code-skill: PASS"
