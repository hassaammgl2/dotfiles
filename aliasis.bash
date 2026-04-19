###########
# EZA (better ls)
###########

alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias la='eza -a --icons'
alias lt='eza --tree --level=2 --icons'
alias l='eza -1'

###########
# BAT (better cat)
###########

alias cat='bat'

###########
# FZF
###########

alias f='fzf'
alias ff='fzf --preview "bat --color=always {}"'

###########
# ZOXIDE (smart cd)
###########

alias cd='z'
alias zi='z -i'

###########
# FD + RIPGREP
###########

alias find='fd'
alias grep='rg'

###########
# GIT POWER ALIASES
###########

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gsw='git switch'

###########
# DOCKER SHORTCUTS
###########

alias d='docker'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dcu='docker compose up -d'
alias dcd='docker compose down'

###########
# SYSTEM
###########

alias update='sudo pacman -Syu'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias neofetch='fastfetch'


source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash
