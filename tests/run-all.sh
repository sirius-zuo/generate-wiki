#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
for test_file in \
  test-source-layout.sh \
  test-contract.sh \
  test-installer.sh \
  test-spec-skill.sh \
  test-code-skill.sh \
  test-router.sh
do
  bash "$ROOT/tests/$test_file"
done
echo "run-all: PASS"
