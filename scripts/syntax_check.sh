#!/usr/bin/env bash
# Validates EVERY *.sh file in the repo (so new scripts on new branches are covered):
#   1. shebang present   2. bash -n   3. shellcheck
set -uo pipefail

fail=0
mapfile -t files < <(find . -type f -name '*.sh' \
  -not -path './.git/*' -not -path './report/*' | sort)

echo "===== BASH SYNTAX CHECK ====="
echo "Scripts found: ${#files[@]}"

if [ "${#files[@]}" -eq 0 ]; then
  echo "[WARN] no .sh files found"
fi

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "[FAIL] shellcheck not installed on this agent"
  echo "SYNTAX: FAIL"
  exit 1
fi

for f in "${files[@]}"; do
  if head -n1 "$f" | grep -q '^#!'; then
    echo "[OK]   shebang    $f"
  else
    echo "[FAIL] shebang    $f (first line must start with #!)"; fail=1
  fi

  if bash -n "$f"; then
    echo "[OK]   bash -n    $f"
  else
    echo "[FAIL] bash -n    $f"; fail=1
  fi

  if shellcheck "$f"; then
    echo "[OK]   shellcheck $f"
  else
    echo "[FAIL] shellcheck $f"; fail=1
  fi
done

if [ "$fail" -eq 0 ]; then echo "SYNTAX: PASS"; else echo "SYNTAX: FAIL"; fi
exit "$fail"
