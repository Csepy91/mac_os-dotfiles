# eza (maintained exa fork) as ls
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first --git'
alias la='eza -lah --icons --group-directories-first --git'
alias lt='eza -lh --tree --level=2 --icons --group-directories-first'
alias l='ll'

alias ..='cd ..'
alias grep='grep --color=auto'
alias dotfiles='cd "${DOTFILES_ROOT:-$HOME/Documents/mac_os-dotfiles}"'

alias g='git'
alias gs='git status'
