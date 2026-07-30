#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
for duplicate in assets references/binding-rules.md; do
  test ! -e "$ROOT/$duplicate"
done
for skill in generate-wiki spec-to-wiki code-to-wiki; do
  test -f "$ROOT/skills/$skill/SKILL.md"
  test -f "$ROOT/skills/$skill/install-manifest.txt"
  while IFS= read -r path; do
    case "$path" in ''|\#*) continue ;; esac
    test -f "$ROOT/$path"
  done < "$ROOT/skills/$skill/install-manifest.txt"
done
echo "test-source-layout: PASS"
