#!/bin/bash
# Weekly maintenance (LaunchAgent, Sundays 22:00).
# Self-contained — does not depend on the dotfiles repo path.
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/bin:/usr/sbin:/sbin:/usr/bin:${PATH:-}"

LOG_DIR="${HOME}/Library/Logs/macos-dotfiles"
mkdir -p "${LOG_DIR}"
LOG="${LOG_DIR}/brew-weekly-upgrade.log"

exec >>"${LOG}" 2>&1
echo "===== $(date '+%Y-%m-%d %H:%M:%S %Z') weekly upgrade start ====="

# --- Homebrew (formulae + casks) ---
if command -v brew >/dev/null 2>&1; then
  echo "brew: $(command -v brew) ($(brew --version | head -1))"
  brew update
  brew upgrade --greedy
else
  echo "warning: brew not found — skip"
fi

# --- Mac App Store (needs App Store sign-in; mas is in Brewfile) ---
if command -v mas >/dev/null 2>&1; then
  echo "mas: $(mas version 2>/dev/null || true)"
  # Do not fail the whole job if nothing is installed / not signed in
  mas upgrade || echo "warning: mas upgrade exited $? (signed in? any mas apps?)"
else
  echo "warning: mas not found — skip App Store"
fi

# --- macOS / system updates: download only ---
# Full `softwareupdate --install` often needs admin auth on Apple Silicon and
# can reboot (-R). Unattended install is unsafe in this user LaunchAgent.
# Downloads stage updates so they install quickly from System Settings later.
if command -v softwareupdate >/dev/null 2>&1; then
  echo "softwareupdate: listing…"
  softwareupdate --list || true
  echo "softwareupdate: downloading (no install / no restart)…"
  softwareupdate --download --all --agree-to-license || echo "warning: softwareupdate download exited $?"
else
  echo "warning: softwareupdate not found — skip"
fi

echo "===== $(date '+%Y-%m-%d %H:%M:%S %Z') weekly upgrade done ====="
