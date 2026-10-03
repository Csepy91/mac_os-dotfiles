#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

load_brew || true
have stow || die "stow is required. Run: ./bootstrap.sh --only prereqs"

stow_dir="${DOTFILES_ROOT}/stow"
action="--restow"

if [[ "${1:-}" == "--delete" ]]; then
  action="--delete"
fi

packages=()
for path in "${stow_dir}"/*/; do
  [[ -d "$path" ]] || continue
  packages+=("$(basename "$path")")
done

if [[ ${#packages[@]} -eq 0 ]]; then
  warn "No stow packages under ${stow_dir}"
  exit 0
fi

cd "$stow_dir"
for package in "${packages[@]}"; do
  log "stow ${action#--} ${package} → ${HOME}"
  stow --verbose=1 --target="$HOME" "${action}" "$package"
done

# Yazi flavors/plugins locked in ~/.config/yazi/package.toml (stowed).
# Flavor files may already be vendored under stow/yazi; this syncs on clean machines.
if [[ "${action}" != "--delete" && -f "${HOME}/.config/yazi/package.toml" ]]; then
  if have ya; then
    log "Yazi packages (ya pkg install)…"
    ya pkg install || warn "ya pkg install failed — check network; flavor may already be vendored"
  else
    warn "ya not on PATH; skip yazi packages (install Yazi via brew first)"
  fi
fi
