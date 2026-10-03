# Shell functions. Keep machine-specific helpers in local.zsh (untracked).

# Yazi: quit with `q` → shell CWD follows last folder; `Q` → quit without cd.
# Use `y`, not bare `yazi`. https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
    builtin cd -- "$cwd"
  fi
  command rm -f -- "$tmp"
}
