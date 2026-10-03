#!/usr/bin/env bash
# Idempotent: install LaunchAgent — Sundays 22:00 brew update/upgrade.
# Missed runs fire when the Mac next wakes (launchd StartCalendarInterval).
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

LABEL="com.macos-dotfiles.brew-weekly-upgrade"
SUPPORT_DIR="${HOME}/Library/Application Support/macos-dotfiles"
BIN="${SUPPORT_DIR}/bin/brew-weekly-upgrade.sh"
PLIST_SRC_DIR="${DOTFILES_ROOT}/install/launchd"
AGENT_PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
JOB_SRC="${PLIST_SRC_DIR}/brew-weekly-upgrade.sh"
UID_NUM="$(id -u)"
DOMAIN="gui/${UID_NUM}"

[[ -f "${JOB_SRC}" ]] || die "missing ${JOB_SRC}"

mkdir -p "${SUPPORT_DIR}/bin" "${HOME}/Library/LaunchAgents" "${HOME}/Library/Logs/macos-dotfiles"

install -m 755 "${JOB_SRC}" "${BIN}"

# Weekday 0 = Sunday (launchd). Hour 22 = 10pm local time.
cat >"${AGENT_PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${BIN}</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Weekday</key>
    <integer>0</integer>
    <key>Hour</key>
    <integer>22</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>ProcessType</key>
  <string>Background</string>
  <key>Nice</key>
  <integer>10</integer>
  <key>LowPriorityIO</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${HOME}/Library/Logs/macos-dotfiles/brew-weekly-upgrade.launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/Library/Logs/macos-dotfiles/brew-weekly-upgrade.launchd.err.log</string>
</dict>
</plist>
EOF

# Reload idempotently (macOS modern launchctl)
if launchctl print "${DOMAIN}/${LABEL}" >/dev/null 2>&1; then
  launchctl bootout "${DOMAIN}/${LABEL}" 2>/dev/null || true
fi
launchctl bootstrap "${DOMAIN}" "${AGENT_PLIST}"
launchctl enable "${DOMAIN}/${LABEL}" 2>/dev/null || true

log "LaunchAgent ${LABEL} loaded — Sundays 22:00 (missed → next wake)"
log "Job script: ${BIN}"
log "Logs: ~/Library/Logs/macos-dotfiles/brew-weekly-upgrade.log"
