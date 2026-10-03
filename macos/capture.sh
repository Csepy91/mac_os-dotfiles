#!/usr/bin/env bash
# Capture curated macOS defaults for later comparison (does not apply anything).
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../install/lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

usage() {
  cat <<'EOF'
Usage: ./macos/capture.sh <label>

Writes human-readable `defaults read` dumps under macos/snapshots/<label>/.

Examples:
  ./macos/capture.sh vm       # this UTM baseline (commit when ready)
  ./macos/capture.sh metal    # bare-metal machine before wipe
  ./macos/compare.sh vm metal
EOF
}

if [[ $# -ne 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
  [[ $# -eq 1 ]] && exit 0
  exit 1
fi

label="$1"
if [[ "$label" == *"/"* ]] || [[ "$label" == "."* ]]; then
  die "label must be a plain name (e.g. vm, metal)"
fi

out="${DOTFILES_ROOT}/macos/snapshots/${label}"
mkdir -p "$out"

# Domains worth comparing across machines. Expand this list over time.
# Missing domains are recorded as MISSING (not an error).
domains=(
  NSGlobalDomain
  com.apple.dock
  com.apple.finder
  com.apple.HIToolbox
  com.apple.AppleMultitouchTrackpad
  com.apple.driver.AppleBluetoothMultitouch.trackpad
  com.apple.AppleMultitouchMouse
  com.apple.driver.AppleBluetoothMultitouch.mouse
  com.apple.screencapture
  com.apple.menuextra.clock
  com.apple.controlcenter
  com.apple.WindowManager
  com.apple.spaces
  com.apple.universalaccess
  com.apple.Accessibility
  com.apple.loginwindow
  com.apple.SoftwareUpdate
  com.apple.Spotlight
  com.apple.symbolichotkeys
  com.apple.SetupAssistant
)

dump_domain() {
  local domain="$1"
  local file="$2"
  if defaults read "$domain" >"$file" 2>/dev/null; then
    return 0
  fi
  printf 'MISSING\n' >"$file"
  return 0
}

log "Capturing macOS defaults → ${out}"

{
  printf 'label=%s\n' "$label"
  printf 'captured_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'hostname=%s\n' "$(scutil --get LocalHostName 2>/dev/null || hostname)"
  printf 'macos=%s\n' "$(sw_vers -productVersion)"
  printf 'build=%s\n' "$(sw_vers -buildVersion)"
  printf 'arch=%s\n' "$(uname -m)"
} >"${out}/META.txt"

for domain in "${domains[@]}"; do
  # NSGlobalDomain file name stays readable; others use the domain string.
  if [[ "$domain" == "NSGlobalDomain" ]]; then
    dump_domain NSGlobalDomain "${out}/NSGlobalDomain.txt"
  else
    dump_domain "$domain" "${out}/${domain}.txt"
  fi
done

# Per-host global prefs (trackpad/display quirks often live here)
if defaults -currentHost read -g >"${out}/currentHost.NSGlobalDomain.txt" 2>/dev/null; then
  :
else
  printf 'MISSING\n' >"${out}/currentHost.NSGlobalDomain.txt"
fi

# Keyword search helpers for Liquid Glass / appearance (domains shift by OS version)
{
  echo "### defaults find glass"
  defaults find glass 2>/dev/null || true
  echo
  echo "### defaults find appearance"
  defaults find appearance 2>/dev/null || true
  echo
  echo "### defaults find Liquid"
  defaults find Liquid 2>/dev/null || true
} >"${out}/search.appearance.txt"

# Spotlight-friendly key peek (also present in NSGlobalDomain dump)
{
  for key in \
    com.apple.swipescrolldirection \
    KeyRepeat \
    InitialKeyRepeat \
    ApplePressAndHoldEnabled \
    AppleInterfaceStyle \
    AppleInterfaceStyleSwitchesAutomatically \
    AppleShowScrollBars \
    NSAutomaticSpellingCorrectionEnabled \
    NSAutomaticCapitalizationEnabled \
    AppleKeyboardUIMode \
    NSGlassTintAmount \
    NSGlassBuddyTintAmount \
    NSGlassEverEditedInBuddy
  do
    printf '%s=' "$key"
    defaults read -g "$key" 2>/dev/null || printf 'MISSING'
    printf '\n'
  done
} >"${out}/keys.input-appearance.txt"

log "Wrote $(find "$out" -type f | wc -l | tr -d ' ') files under macos/snapshots/${label}"
log "Compare later: ./macos/compare.sh vm ${label}"
