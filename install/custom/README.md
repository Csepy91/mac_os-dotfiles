# Custom installers

Add one `*.sh` script per app that **cannot** go in the Brewfile (not a
formula, cask, or Mac App Store title).

Each script must be idempotent: if the app is already present, print a skip
message and exit 0.

`install/custom.sh` runs every `*.sh` in this directory during bootstrap
(`./bootstrap.sh` → phase `custom`, after `brew`). Do not put a runner here;
keep this folder as app scripts only.

## Current scripts

| Script | Installs |
| --- | --- |
| `brew-weekly-upgrade.sh` | LaunchAgent Sundays 22:00: brew upgrade, `mas upgrade`, `softwareupdate --download` (no OS auto-install) |
| `iina-defaults.sh` | System default media → IINA (`utiluti`; short UTI list to limit Allow popups) |
| `sketchybar-borders.sh` | Build SbarLua; `brew services start` sketchybar + borders |
| `yazi-launcher.sh` | `/Applications/Yazi.app` (Ghostty + yazi in `$HOME`; quit → shell stays in last folder) |
| `assets/yazi-logo.png` | Official [Yazi logo](https://github.com/sxyazi/yazi/blob/main/assets/logo.png) → app icon |

Job source lives in `install/launchd/`; the custom installer copies it to
`~/Library/Application Support/macos-dotfiles/bin/` and loads the agent.
