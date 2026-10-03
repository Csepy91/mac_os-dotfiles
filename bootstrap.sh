#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install/lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--only PHASE]

Idempotent macOS bootstrap. Phases, in order:

  prereqs   Xcode CLT, Homebrew, stow, mas
  brew      Brewfile (formulae, casks, mas)
  custom    install/custom/*.sh
  stow      GNU Stow packages into $HOME
  macos     macos/defaults.sh (no-op until harvested)

Options:
  --only PHASE   Run a single phase (prereqs|brew|custom|stow|macos)
  -h, --help     Show this help
EOF
}

run_phase() {
  local phase="$1"
  case "$phase" in
    prereqs) bash "${DOTFILES_ROOT}/install/prereqs.sh" ;;
    brew)    bash "${DOTFILES_ROOT}/install/brew.sh" ;;
    custom)  bash "${DOTFILES_ROOT}/install/custom.sh" ;;
    stow)    bash "${DOTFILES_ROOT}/install/stow.sh" ;;
    macos)   bash "${DOTFILES_ROOT}/macos/defaults.sh" ;;
    *)
      die "Unknown phase: ${phase}"
      ;;
  esac
}

only=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      [[ $# -ge 2 ]] || die "--only requires a phase name"
      only="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

if [[ -n "$only" ]]; then
  log "Phase: ${only}"
  run_phase "$only"
  log "Done"
  exit 0
fi

for phase in prereqs brew custom stow macos; do
  log "Phase: ${phase}"
  run_phase "$phase"
done

log "Bootstrap finished. Open a new shell (or: exec zsh) to load aliases."
