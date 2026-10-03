#!/usr/bin/env bash
# Diff two snapshots from macos/capture.sh. Does not apply settings.
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../install/lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

usage() {
  cat <<'EOF'
Usage: ./macos/compare.sh <label-a> <label-b>

Compares macos/snapshots/<label-a> vs macos/snapshots/<label-b>.
Only prints files that differ. Exit 0 if identical, 1 if differences, 2 on error.

Example:
  ./macos/capture.sh metal
  ./macos/compare.sh vm metal
EOF
}

if [[ $# -ne 2 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
  [[ $# -eq 2 ]] && exit 0
  exit 2
fi

a="${DOTFILES_ROOT}/macos/snapshots/$1"
b="${DOTFILES_ROOT}/macos/snapshots/$2"

[[ -d "$a" ]] || die "missing snapshot: $a (run ./macos/capture.sh $1)"
[[ -d "$b" ]] || die "missing snapshot: $b (run ./macos/capture.sh $2)"

log "Comparing $1 → $2"
differs=0

# Union of filenames in both trees
names="$(
  {
    find "$a" -type f -exec basename {} \;
    find "$b" -type f -exec basename {} \;
  } | sort -u
)"

while IFS= read -r name; do
  [[ -n "$name" ]] || continue
  [[ "$name" == "META.txt" ]] && continue
  fa="${a}/${name}"
  fb="${b}/${name}"
  if [[ ! -f "$fa" ]]; then
    printf 'ONLY in %s: %s\n' "$2" "$name"
    differs=1
    continue
  fi
  if [[ ! -f "$fb" ]]; then
    printf 'ONLY in %s: %s\n' "$1" "$name"
    differs=1
    continue
  fi
  if ! diff -u "$fa" "$fb" >"${TMPDIR:-/tmp}/macos-compare.$$.diff" 2>/dev/null; then
    printf '\n===== %s =====\n' "$name"
    cat "${TMPDIR:-/tmp}/macos-compare.$$.diff"
    differs=1
  fi
  rm -f "${TMPDIR:-/tmp}/macos-compare.$$.diff"
done <<<"$names"

if [[ "$differs" -eq 0 ]]; then
  log "No differences (excluding META.txt)"
  exit 0
fi

log "Differences found. Pick keys you want into macos/harvested.flags later — do not apply blindly."
exit 1
