# Capturing and comparing macOS defaults

Goal: keep a **VM baseline** (this UTM sandbox; only Liquid Glass was changed by
hand) and later capture **bare metal**, then **diff**. You choose which deltas
to harvest into `macos/harvested.flags` — nothing is applied automatically.

## Workflow

### 1. Baseline on this VM (do once, commit)

```sh
./macos/capture.sh vm
# or: make capture-vm
```

Writes `macos/snapshots/vm/`. Commit that tree so it travels with the clone.

### 2. Before wiping bare metal

On the metal Mac, clone this repo (or copy it), then:

```sh
./macos/capture.sh metal
./macos/compare.sh vm metal
# or: make compare-metal
```

Review the diff. Copy only the settings you want into `macos/harvested.flags`
(or a future `macos/defaults.sh` body). Skip noisy or machine-specific keys
(UUIDs, display IDs, iCloud).

### 3. After reinstall

Bootstrap apps/dotfiles first. Apply harvested defaults only when
`macos/harvested.flags` exists (`./bootstrap.sh --only macos`).

## What gets captured

Curated domains (see `macos/capture.sh`): Dock, Finder, trackpad/mouse,
HIToolbox, WindowManager, scroll/keyboard-related `NSGlobalDomain` keys, plus
`defaults find` for glass/appearance/Liquid.

Expand the domain list in `capture.sh` when you discover more you care about,
then re-run capture on both machines.

## Manual one-off reads

```sh
defaults read -g com.apple.swipescrolldirection
defaults read -g KeyRepeat
defaults read -g InitialKeyRepeat
defaults read com.apple.HIToolbox AppleEnabledInputSources
defaults -currentHost read -g
```

## Git policy

- Commit `macos/snapshots/vm/` (baseline).
- Leave other labels (`metal`, experiments) untracked — see `.gitignore`.
- Do not commit raw `.plist` exports with machine identifiers until reviewed.
