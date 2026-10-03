#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

load_brew || die "Homebrew is required. Run: ./bootstrap.sh --only prereqs"

log "Running brew bundle (idempotent)…"
brew bundle --file="${DOTFILES_ROOT}/Brewfile"

# Prefer Homebrew zsh over /bin/zsh (newer; matches Brewfile).
ensure_login_shell_zsh() {
  local zsh_path current
  zsh_path="$(brew --prefix)/bin/zsh"
  [[ -x "$zsh_path" ]] || die "Homebrew zsh missing at ${zsh_path} (is brew \"zsh\" in the Brewfile?)"

  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    log "Adding ${zsh_path} to /etc/shells (sudo)…"
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  else
    log "Already in /etc/shells: ${zsh_path}"
  fi

  current="$(dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}')"
  if [[ "$current" == "$zsh_path" ]]; then
    log "Login shell already ${zsh_path}"
    return 0
  fi

  log "Setting login shell ${current:-unknown} → ${zsh_path} (password prompt possible)…"
  chsh -s "$zsh_path"
  log "Login shell updated. New Terminal/Ghostty tabs will use Homebrew zsh."
}

ensure_login_shell_zsh
