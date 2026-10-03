#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

ensure_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools already installed"
    return 0
  fi

  log "Installing Xcode Command Line Tools (GUI prompt)…"
  xcode-select --install >/dev/null 2>&1 || true
  die "Finish the Command Line Tools installer, then rerun ./bootstrap.sh"
}

ensure_homebrew() {
  if load_brew; then
    log "Homebrew already installed ($(brew --prefix))"
    return 0
  fi

  log "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew || die "Homebrew installed but brew is not on PATH"
}

ensure_brew_formula() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    log "brew formula already installed: ${formula}"
    return 0
  fi
  log "Installing brew formula: ${formula}"
  brew install "$formula"
}

ensure_clt
ensure_homebrew
ensure_brew_formula stow
ensure_brew_formula mas
