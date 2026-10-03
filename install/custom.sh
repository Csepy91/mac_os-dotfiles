#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

custom_dir="${DOTFILES_ROOT}/install/custom"
shopt -s nullglob
scripts=("${custom_dir}"/*.sh)
shopt -u nullglob

if [[ ${#scripts[@]} -eq 0 ]]; then
  log "No custom installers in install/custom (skipping)"
  exit 0
fi

for script in "${scripts[@]}"; do
  log "Custom installer: $(basename "$script")"
  # shellcheck disable=SC1090
  bash "$script"
done
