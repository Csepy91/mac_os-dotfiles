#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../install/lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

# Harvested defaults live here later. Do not write Liquid Glass, keyboard,
# scroll direction, or similar until they are copied from bare metal.
#
# Candidates (see macos/CAPTURE.md):
#   NSGlobalDomain com.apple.swipescrolldirection
#   NSGlobalDomain KeyRepeat / InitialKeyRepeat
#   com.apple.HIToolbox AppleEnabledInputSources
#   com.apple.dock
#   Liquid Glass / appearance-related domains once identified

if [[ ! -f "${DOTFILES_ROOT}/macos/harvested.flags" ]]; then
  log "macos/defaults.sh: no harvested settings yet (skipping)"
  exit 0
fi

log "Applying harvested macOS defaults…"
# shellcheck disable=SC1091
source "${DOTFILES_ROOT}/macos/harvested.flags"
