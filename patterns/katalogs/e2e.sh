#!/usr/bin/env bash
# Run e2e tests for one or all katalog patterns.
#
# Usage:
#   ./e2e.sh <version>          run e2e for all katalogs
#   ./e2e.sh <version> <name>   run e2e for one katalog
#
# Examples:
#   ./e2e.sh v1.0.0
#   ./e2e.sh v1.0.0 postgres
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <version> [name]"
  echo "  version  katalog version, e.g. v1.0.0"
  echo "  name     katalog name (optional — omit to run all)"
  exit 1
fi

VERSION="$1"
NAME="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

run_e2e() {
  local name="$1"
  local e2e_file="$SCRIPT_DIR/$name/$VERSION/e2e.yaml"
  if [ ! -f "$e2e_file" ]; then
    echo "  ~ $name/$VERSION: no e2e.yaml found, skipping"
    return 0
  fi
  echo "→ Running e2e: ${name} ${VERSION}"
  ${HOME}/.orkestra/bin/ork e2e -f "$e2e_file"
}

if [ -n "$NAME" ]; then
  run_e2e "$NAME"
else
  failed=""
  for d in "$SCRIPT_DIR"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [ -d "$d/$VERSION" ] || continue
    echo ""
    echo "══════════════════════════════════════"
    echo "  $name"
    echo "══════════════════════════════════════"
    if ! run_e2e "$name"; then
      failed="$failed $name"
    fi
  done
  echo ""
  if [ -n "$failed" ]; then
    echo "✖ Failed:$failed"
    exit 2
  fi
  echo "✔ All katalog e2e tests passed at $VERSION"
fi
