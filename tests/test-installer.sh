#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

"$ROOT/scripts/install.sh" --skill spec-to-wiki --dest "$TMP/skills"
test -f "$TMP/skills/spec-to-wiki/SKILL.md"
test -f "$TMP/skills/spec-to-wiki/shared/assets/TEMPLATE.md"
test -f "$TMP/skills/spec-to-wiki/.wiki-skill-install"
grep -Fq 'canonical-source: shared/' "$TMP/skills/spec-to-wiki/.wiki-skill-install"
grep -Fq 'repository-revision:' "$TMP/skills/spec-to-wiki/.wiki-skill-install"
test ! -e "$TMP/skills/code-to-wiki"

"$ROOT/scripts/install.sh" --skill generate-wiki --dest "$TMP/bundle"
for skill in generate-wiki spec-to-wiki code-to-wiki; do
  test -f "$TMP/bundle/$skill/SKILL.md"
done

DRY="$TMP/dry"
output=$("$ROOT/scripts/install.sh" --skill code-to-wiki --dest "$DRY" --dry-run)
grep -Fq 'INSTALL code-to-wiki' <<< "$output"
test ! -e "$DRY"

printf '\nlocal edit\n' >> "$TMP/skills/spec-to-wiki/SKILL.md"
if "$ROOT/scripts/install.sh" --skill spec-to-wiki --dest "$TMP/skills"; then
  echo "installer overwrote a locally modified file" >&2
  exit 1
fi
"$ROOT/scripts/install.sh" --skill spec-to-wiki --dest "$TMP/skills" --force
! grep -Fq 'local edit' "$TMP/skills/spec-to-wiki/SKILL.md"
echo "test-installer: PASS"
