# macOS dotfiles

Idempotent bootstrap for a fresh Mac: Homebrew apps, optional custom
installers, and GNU Stow of dotfiles.

Clone this repo and run `./bootstrap.sh`. The same script is the reinstall path.

## Bootstrap

```sh
git clone <this-repo> ~/Documents/mac_os-dotfiles
cd ~/Documents/mac_os-dotfiles
./bootstrap.sh
```

Or: `make bootstrap`.

### Phases

| Phase | What it does |
| --- | --- |
| `prereqs` | Xcode CLT, Homebrew, `stow`, `mas` |
| `brew` | `brew bundle` against `Brewfile` |
| `custom` | `install/custom/*.sh` (Yazi.app, IINA defaults, SketchyBar/borders, weekly brew LaunchAgent, …) |
| `stow` | Link `stow/*` into `$HOME` |

```sh
./bootstrap.sh --only brew
./bootstrap.sh --only stow
make unstow
```

GUI apps currently in the Brewfile: Cursor, Ghostty, Karabiner-Elements,
UTM, LibreOffice, GeForce NOW, Transmission, TeamViewer, IINA, OmniWM, Raycast.
Vorssaint is commented out until bare-metal setup. App Store (`mas`) lines for
AdGuard Mini and Xcode are commented out until you want them. Ghostty config is
stowed at `~/.config/ghostty/config.ghostty` (Catppuccin Frappe, glass opacity).
Karabiner complex modifications can get a `stow/karabiner` package later.
OmniWM: grant Accessibility + Input Monitoring; keep “Displays have separate
Spaces” on; do not run another tiling WM alongside it. Enable IPC in
`~/.config/omniwm/settings.toml` (`ipcEnabled = true`) for OmniCast and SketchyBar.
Raycast is the app launcher; install [OmniCast](https://www.raycast.com/imprisonedmind/omni-cast)
from the Raycast Store (not brew) and leave Raycast’s own Window Management off.
CLI: Homebrew `zsh`, `git`, `gh`, `uv`, `ncdu`, `btop`, plus Yazi and its
preview/search dependencies (`ffmpeg`, `sevenzip`, `jq`, `poppler`, `fd`,
`ripgrep`, `fzf`, `zoxide`, `resvg`, `imagemagick`, JetBrains Mono Nerd Font,
Symbols Nerd Font). Desktop bar: `sketchybar` + `borders` (FelixKratz tap) with
Catppuccin Frappe configs under `stow/sketchybar` and `stow/borders`.

If Cursor (or another cask) is already installed, Homebrew leaves it alone.

## SketchyBar + JankyBorders

After brew + custom + stow (if brew refuses the FelixKratz tap:
`brew trust felixkratz/formulae`, then rerun brew):

1. Grant **Accessibility** to SketchyBar and borders (Privacy & Security).
2. Hide the native menu bar: **System Settings → Control Center →
   Automatically hide and show the menu bar → Always**
   (or: `defaults write -g AppleMenuBarVisibleInFullscreen -bool false` and
   `defaults write -g _HIHideMenuBar -bool true`; may need logout).
3. In OmniWM settings (not stowed yet):
   - `ipcEnabled = true`
   - disable built-in `[borders]` and `[workspaceBar]` (external tools own those)
   - `[gaps.outer] top ≈ 38` so windows clear the bar
4. Reload if needed: `sketchybar --reload` and `brew services restart borders`.

Custom phase builds [SbarLua](https://github.com/FelixKratz/SbarLua) once and starts
`brew services` for sketchybar + borders.

## Layout

- `Brewfile` — formulae, casks, `mas` App Store IDs
- `install/custom/` — one script per non-brew app (`yazi-launcher.sh` → `/Applications/Yazi.app`)
- `stow/` — packages that mirror `$HOME` (e.g. `stow/zsh/.zshrc` → `~/.zshrc`)

## Inspiration

Patterns for OmniWM + SketchyBar + JankyBorders (revisit later; we use Catppuccin
Frappe, not their Teto theme):

- [iluvgirlswithglasses/dots-macos](https://github.com/iluvgirlswithglasses/dots-macos)
- SketchyBar submodule: [iluvgirlswithglasses/sketchybar](https://github.com/iluvgirlswithglasses/sketchybar)

Useful ideas there: Lua bar layout, `omniwmctl` workspace watcher, `bordersrc`,
outer top gap, and turning off OmniWM’s built-in workspace bar/borders.

## Git identity

Copy the example and fill it in (untracked):

```sh
cp stow/git/.gitconfig.local.example ~/.gitconfig.local
```

If `stow` refuses to link because `~/.zshrc` or `~/.gitconfig` already exists,
move those files aside and rerun `./bootstrap.sh --only stow`.

## Secrets

Do not commit SSH keys, tokens, or `*.local` files. Machine-specific zsh goes
in `~/.config/zsh/local.zsh`.
