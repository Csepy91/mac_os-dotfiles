# Homebrew on Apple Silicon / Intel
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# History — small but useful
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE EXTENDED_HISTORY

# Completion
autoload -Uz compinit
compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

ZSH_CONFIG="${HOME}/.config/zsh"
if [[ -d "$ZSH_CONFIG" ]]; then
  [[ -f "${ZSH_CONFIG}/path.zsh" ]] && source "${ZSH_CONFIG}/path.zsh"
  [[ -f "${ZSH_CONFIG}/prompt.zsh" ]] && source "${ZSH_CONFIG}/prompt.zsh"
  [[ -f "${ZSH_CONFIG}/aliases.zsh" ]] && source "${ZSH_CONFIG}/aliases.zsh"
  [[ -f "${ZSH_CONFIG}/functions.zsh" ]] && source "${ZSH_CONFIG}/functions.zsh"
  [[ -f "${ZSH_CONFIG}/local.zsh" ]] && source "${ZSH_CONFIG}/local.zsh"
fi

# zoxide: shell `z`/`zi`, and Yazi's Z jumper
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# fzf keybindings (Ctrl-R history, Ctrl-T files) when brew fzf is present
if [[ -n "${HOMEBREW_PREFIX:-}" && -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
fi

# Autosuggestions then syntax highlighting (highlighting must be last).
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  # Catppuccin Frappe overlay0 — soft ghost text
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#737994'
  [[ -f "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
    source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
