#!/usr/bin/env bash
# Push one or all katalog patterns to the registry.
#
# Usage:
#   ./push.sh <version>                 push all katalogs
#   ./push.sh <version> <name>          push one katalog
#   ./push.sh <version> <name> --force  push, skip e2e gate
#
# Examples:
#   ./push.sh v1.0.0
#   ./push.sh v1.0.0 postgres
#   ./push.sh v1.0.0 redis --force
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <version> [name] [--force]"
  echo "  version  katalog version, e.g. v1.0.0"
  echo "  name     katalog name (optional — omit to push all)"
  echo "  --force  skip e2e gate"
  exit 1
fi

VERSION="$1"
NAME="${2:-}"
FORCE=""

# Allow --force as second or third argument
for arg in "$@"; do
  [ "$arg" = "--force" ] && FORCE="--force"
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

push_one() {
  local name="$1"
  local dir="$SCRIPT_DIR/$name/$VERSION"
  if [ ! -d "$dir" ]; then
    echo "✖ $name/$VERSION: directory not found ($dir)"
    return 1
  fi
  echo "→ Pushing katalog ${name}:${VERSION}${FORCE:+ (--force)}"
  ${HOME}/.orkestra/bin/ork registry push "${name}:${VERSION}" "$dir" $FORCE
  echo "✔ Pushed ${name}:${VERSION}"
}

if [ -n "$NAME" ] && [ "$NAME" != "--force" ]; then
  push_one "$NAME"
else
  failed=""
  for d in "$SCRIPT_DIR"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [ -d "$d/$VERSION" ] || continue
    echo ""
    if ! push_one "$name"; then
      failed="$failed $name"
    fi
  done
  echo ""
  if [ -n "$failed" ]; then
    echo "✖ Failed:$failed"
    exit 2
  fi
  echo "✔ All katalogs pushed at $VERSION"
fi
