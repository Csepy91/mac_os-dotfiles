#!/usr/bin/env bash
# Idempotent: build SbarLua and start sketchybar + borders brew services.
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

load_brew || die "Homebrew required (run ./bootstrap.sh --only brew first)"

# Homebrew may refuse third-party taps until trusted (Homebrew 5+).
if brew trust --help >/dev/null 2>&1; then
  brew trust felixkratz/formulae >/dev/null 2>&1 || true
fi

have sketchybar || die "sketchybar not found (run ./bootstrap.sh --only brew first)"
have borders || die "borders not found (run ./bootstrap.sh --only brew first)"
have lua || die "lua not found (Brewfile)"
have git || die "git required to build SbarLua"
have make || die "make / Xcode CLT required to build SbarLua"

SBAR_LUA_SO="${HOME}/.local/share/sketchybar_lua/sketchybar.so"

if [[ -f "${SBAR_LUA_SO}" ]]; then
  log "SbarLua already installed: ${SBAR_LUA_SO}"
else
  log "Building SbarLua…"
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' EXIT
  git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "${tmp}/SbarLua"
  (
    cd "${tmp}/SbarLua"
    make install
  )
  rm -rf "${tmp}"
  trap - EXIT
  [[ -f "${SBAR_LUA_SO}" ]] || die "SbarLua build finished but ${SBAR_LUA_SO} missing"
  log "SbarLua installed at ${SBAR_LUA_SO}"
fi

start_service() {
  local name="$1"
  if brew services list | awk -v n="${name}" '$1 == n && $2 == "started" { found=1 } END { exit !found }'; then
    log "${name} service already started"
    return 0
  fi
  log "Starting brew service: ${name}"
  brew services start "${name}"
}

start_service sketchybar
start_service borders

log "Grant Accessibility to SketchyBar and borders (Privacy & Security)."
log "Optional: add them under Login Items. OmniWM: ipc on, workspaceBar/borders off, outer top gap ~38."
