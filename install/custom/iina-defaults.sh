#!/usr/bin/env bash
# Idempotent: make IINA the system default for common video/audio types.
# Uses utiluti (duti is unreliable on recent macOS).
#
# Recent macOS shows an Allow dialog *per UTI*. Keep this list short on purpose.
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../lib.sh
source "${DOTFILES_ROOT}/install/lib.sh"

load_brew || true

BUNDLE_ID="com.colliderli.iina"

if [[ ! -d "/Applications/IINA.app" ]]; then
  die "IINA.app missing — install cask iina via brew first"
fi

have utiluti || die "utiluti missing — add brew \"utiluti\" to Brewfile / run brew phase"

# Curated high-traffic types only (each may trigger one macOS Allow prompt).
utis=(
  public.mpeg-4              # .mp4
  com.apple.quicktime-movie  # .mov
  com.apple.m4v-video        # .m4v
  public.avi
  public.mpeg                # .mpg/.mpeg
  org.webmproject.webm       # .webm
  public.mp3
  public.aac-audio           # .aac
  com.apple.m4a-audio        # .m4a
  com.microsoft.waveform-audio # .wav
  org.xiph.flac
  org.xiph.ogg-audio         # .ogg/.opus
)

# MKV UTI appears as IINA's own type once IINA is installed
if mkv_uti="$(utiluti get-uti mkv 2>/dev/null)" && [[ -n "${mkv_uti}" ]]; then
  utis+=("${mkv_uti}")
fi

log "Setting IINA as default for ${#utis[@]} common media types…"
log "(macOS may show one Allow dialog per type — that is expected)"

failed=0
for uti in "${utis[@]}"; do
  # Skip if already IINA (avoids re-prompting on re-runs)
  current="$(utiluti type "${uti}" 2>/dev/null | tail -1 || true)"
  if [[ "${current}" == "${BUNDLE_ID}" ]]; then
    continue
  fi
  if utiluti type set "${uti}" "${BUNDLE_ID}" >/dev/null 2>&1; then
    continue
  fi
  warn "utiluti failed for ${uti} — click Allow if prompted, then re-run custom"
  failed=$((failed + 1))
done

for sample in mp4 mkv mp3 mov webm; do
  sample_uti="$(utiluti get-uti "${sample}" 2>/dev/null || true)"
  handler="unknown"
  if [[ -n "${sample_uti}" ]]; then
    handler="$(utiluti type "${sample_uti}" 2>/dev/null | head -1 || true)"
  fi
  log "default for .${sample}: ${handler:-unknown}"
done

if (( failed > 0 )); then
  warn "${failed} type(s) not applied — approve dialogs, then: ./bootstrap.sh --only custom"
else
  log "IINA is the system default for common media types"
fi
