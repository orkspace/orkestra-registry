#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <version> [dir]"
  echo "Example: $0 v0.1.0 ."
  exit 1
fi

VERSION="$1"
DIR="${2:-.}"

cd "$DIR"

for d in */; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"

  echo "→ Pushing motif pattern: ${name}:${VERSION}"
  if ! ${HOME}/.orkestra/bin/ork registry push "${name}:${VERSION}" "./${d%/}"; then
    echo "✖ Failed to push ${name}:${VERSION}"
    exit 2
  fi
  echo "✔ Pushed ${name}:${VERSION}"
done

echo "All motif patterns pushed with version ${VERSION}"
