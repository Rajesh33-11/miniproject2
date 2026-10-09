#!/usr/bin/env bash
# Dockerfile validation: hadolint (lint) + docker build (real build)
set -uo pipefail
TAG="${1:-test-image}"

echo "===== DOCKERFILE CHECK ====="
if docker run --rm -i hadolint/hadolint < Dockerfile; then
  echo "[OK]   hadolint"
else
  echo "[FAIL] hadolint"
  echo "DOCKERFILE: FAIL"
  exit 1
fi

if docker build -q -t "$TAG" . >/dev/null; then
  echo "[OK]   docker build"
else
  echo "[FAIL] docker build"
  echo "DOCKERFILE: FAIL"
  exit 1
fi
echo "DOCKERFILE: PASS"
