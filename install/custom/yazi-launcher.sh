#!/usr/bin/env bash
# Idempotent: /Applications/Yazi.app — opens Ghostty running yazi (Spotlight/Dock).
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

# Prefer /Applications (Spotlight + Finder); fall back to ~/Applications.
APP_ROOT="/Applications/Yazi.app"
if ! mkdir -p "${APP_ROOT}/Contents/MacOS" 2>/dev/null; then
  APP_ROOT="${HOME}/Applications/Yazi.app"
  mkdir -p "${APP_ROOT}/Contents/MacOS"
fi
MACOS_DIR="${APP_ROOT}/Contents/MacOS"
RES_DIR="${APP_ROOT}/Contents/Resources"
PLIST="${APP_ROOT}/Contents/Info.plist"
BIN="${MACOS_DIR}/Yazi"
STARTUP_TXT="${RES_DIR}/startup.txt"
LOGO_SRC="${DOTFILES_ROOT}/install/custom/assets/yazi-logo.png"
ICNS_OUT="${RES_DIR}/AppIcon.icns"

if [[ ! -d "/Applications/Ghostty.app" ]]; then
  die "Ghostty.app required for Yazi launcher (install via Brewfile first)"
fi

mkdir -p "${RES_DIR}"

if [[ -x /opt/homebrew/bin/yazi ]]; then
  yazi_bin=/opt/homebrew/bin/yazi
elif [[ -x /usr/local/bin/yazi ]]; then
  yazi_bin=/usr/local/bin/yazi
else
  die "yazi not found (brew install yazi / ./bootstrap.sh --only brew)"
fi

# Official logo: https://github.com/sxyazi/yazi/blob/main/assets/logo.png
install_icon() {
  [[ -f "${LOGO_SRC}" ]] || {
    warn "Missing ${LOGO_SRC}; app will have no custom icon"
    return 0
  }
  have sips || {
    warn "sips not available; skip icon"
    return 0
  }
  have iconutil || {
    warn "iconutil not available; skip icon"
    return 0
  }

  local iconset tmp
  tmp="$(mktemp -d)"
  iconset="${tmp}/AppIcon.iconset"
  mkdir -p "${iconset}"

  # Square canvas (logo is slightly non-square)
  local square="${tmp}/logo-square.png"
  sips -z 1024 1024 "${LOGO_SRC}" --out "${square}" >/dev/null

  local size
  for size in 16 32 128 256 512; do
    sips -z "${size}" "${size}" "${square}" --out "${iconset}/icon_${size}x${size}.png" >/dev/null
    sips -z $((size * 2)) $((size * 2)) "${square}" --out "${iconset}/icon_${size}x${size}@2x.png" >/dev/null
  done

  iconutil -c icns "${iconset}" -o "${ICNS_OUT}"
  rm -rf "${tmp}"
  log "Installed AppIcon.icns from official Yazi logo"
}

install_icon

# Bytes typed into a normal Ghostty shell (no `-e` → no "Allow Execute?" dialog).
# Trailing newline submits the line; `; exit` closes the window when yazi quits.
printf '%s "%s"; exit\n' "${yazi_bin}" "${HOME}" >"${STARTUP_TXT}"

cat >"${BIN}" <<EOF
#!/bin/bash
set -euo pipefail
home="\${HOME:-/Users/\$(id -un)}"
startup="${STARTUP_TXT}"
if [[ ! -f "\${startup}" ]]; then
  osascript -e 'display alert "Yazi launcher broken" message "Re-run: ./bootstrap.sh --only custom" as critical'
  exit 1
fi
# Ghostty cannot disable -e confirmations (security). Use input=path: instead.
exec open -na Ghostty.app --args \\
  --working-directory="\${home}" \\
  --quit-after-last-window-closed=true \\
  --input=path:\${startup}
EOF
chmod 755 "${BIN}"
rm -f "${MACOS_DIR}/Yazi-run"

cat >"${PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>Yazi</string>
  <key>CFBundleIdentifier</key>
  <string>com.csepy.yazi-launcher</string>
  <key>CFBundleName</key>
  <string>Yazi</string>
  <key>CFBundleDisplayName</key>
  <string>Yazi</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleVersion</key>
  <string>3</string>
  <key>CFBundleShortVersionString</key>
  <string>1.2</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
EOF

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f "${APP_ROOT}" >/dev/null 2>&1 || true
# Nudge Dock/Spotlight to pick up the new icon
killall Finder Dock 2>/dev/null || true

log "Yazi.app ready at ${APP_ROOT} (official logo icon; starts in \$HOME)"
