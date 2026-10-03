# macOS dotfiles

Idempotent bootstrap for a fresh Mac: Homebrew apps, optional custom
installers, GNU Stow of dotfiles, then macOS defaults (harvested later).

This UTM VM is the authoring machine. When the setup feels right, clone the
same repo onto a **clean VM** and run `./bootstrap.sh`. After that replay is
boring, reinstall bare metal and run the same script.

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
| `custom` | `install/custom/*.sh` (Yazi.app, IINA defaults, weekly brew LaunchAgent, …) |
| `stow` | Link `stow/*` into `$HOME` |
| `macos` | `macos/defaults.sh` (no-op until harvest) |

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
`~/.config/omniwm/settings.toml` (`ipcEnabled = true`) for OmniCast.
Raycast is the app launcher; install [OmniCast](https://www.raycast.com/imprisonedmind/omni-cast)
from the Raycast Store (not brew) and leave Raycast’s own Window Management off.
CLI: Homebrew `zsh`, `git`, `gh`, `uv`, `ncdu`, `btop`, plus Yazi and its
preview/search dependencies (`ffmpeg`, `sevenzip`, `jq`, `poppler`, `fd`,
`ripgrep`, `fzf`, `zoxide`, `resvg`, `imagemagick`, JetBrains Mono Nerd Font,
Symbols Nerd Font).

If Cursor (or another cask) is already installed, Homebrew leaves it alone.

## Layout

- `Brewfile` — formulae, casks, `mas` App Store IDs
- `install/custom/` — one script per non-brew app (`yazi-launcher.sh` → `/Applications/Yazi.app`)
- `stow/` — packages that mirror `$HOME` (e.g. `stow/zsh/.zshrc` → `~/.zshrc`)
- `macos/` — defaults capture/compare; see `macos/CAPTURE.md` before wiping bare metal

## macOS settings baseline

This VM is almost stock (Liquid Glass was tweaked). Capture a baseline, commit
`macos/snapshots/vm/`, then on bare metal capture and diff — cherry-pick only
what you want into `macos/harvested.flags` later:

```sh
make capture-vm                 # on this UTM VM
# … later on bare metal …
make capture-metal
make compare-metal
```


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
