# Minimal Catppuccin Frappe prompt — cwd, git, exit status. No Starship / OMZ.
# Colors: https://github.com/catppuccin/catppuccin (Frappe)

autoload -Uz vcs_info
setopt prompt_subst

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{#a6d189}+%f'    # green
zstyle ':vcs_info:*' unstagedstr '%F{#e5c890}*%f'  # yellow
zstyle ':vcs_info:git:*' formats ' %F{#ca9ee6}%b%c%u%f'           # mauve branch
zstyle ':vcs_info:git:*' actionformats ' %F{#ca9ee6}%b%f%F{#e78284}|%a%f%c%u'

# Last command exit (shown only on failure)
typeset -g _prompt_status=""

precmd() {
  local ec=$?
  vcs_info
  if (( ec != 0 )); then
    _prompt_status=" %F{#e78284}✗ ${ec}%f"
  else
    _prompt_status=""
  fi
}

# SSH: show user@host so remote sessions speak clearly
typeset -g _prompt_host=""
if [[ -n "${SSH_CONNECTION:-}" ]]; then
  _prompt_host="%F{#ef9f76}%n@%m%f "
fi

# Line 1: [host] path  branch±  ✗ N
# Line 2: ❯
PROMPT=$'\n${_prompt_host}%F{#8caaee}%~%f${vcs_info_msg_0_}${_prompt_status}\n%(?.%F{#a6d189}.%F{#e78284})❯%f '
RPROMPT=''