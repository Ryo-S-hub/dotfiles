#!/usr/bin/env zsh
# FZF Custom Functions - Modular configuration

# ============================================================================
# Process Management
# ============================================================================
# Kill process with fzf
fkill() {
    local pid
    pid=$(ps aux | sed 1d | fzf -m | awk '{print $2}')
    
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# ============================================================================
# Docker Functions
# ============================================================================
# Docker container interactive
fdc() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')
    
    [[ -n "$cid" ]] && docker start "$cid" && docker exec -it "$cid" /bin/bash
}

# Docker image remove
fdi() {
    docker images | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ print $3 }' | xargs -r docker rmi
}

# Docker logs
dcl() {
    local service
    service=$(docker-compose ps --services 2>/dev/null | fzf)
    [[ -n "$service" ]] && docker-compose logs -f "$service"
}

# ============================================================================
# Git Functions
# ============================================================================
# Git branch checkout
fbr() {
    local branches branch
    branches=$(git --no-pager branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# Git branch checkout (including remotes)
fbrr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Git add with preview
fadd() {
    local files
    files=$(git status --short | grep -v '^[AMD]' | awk '{print $2}' | fzf -m --preview 'git diff --color=always {}')
    
    if [[ -n "$files" ]]; then
        echo "$files" | xargs git add
        git status --short
    fi
}

# Git log browser
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                  (grep -o '[a-f0-9]\{7\}' | head -1 |
                  xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                  {}
FZF-EOF"
}

# ============================================================================
# Directory Navigation
# ============================================================================
# CD to recent directory
fzf-cdr() {
    local selected_dir
    selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse --preview 'eza --tree --color=always --level=2 --icons {}')
    if [[ -n "$selected_dir" ]]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}

# CD to git root subdirectory
fdgit() {
    local top_dir dir
    top_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -z "$top_dir" ]]; then
        echo "Not in a Git repository."
        return 1
    fi
    
    dir="$(cd "$top_dir" || return 1; fd --type d --exclude .git | fzf --preview 'eza --tree --color=always --level=2 --icons {}')"
    [[ -n "$dir" ]] && cd "$top_dir/$dir"
}

# GHQ repository navigation
fghq() {
    local selected
    selected=$(ghq list | fzf --preview "bat --color=always --style=numbers --line-range=:50 $(ghq root)/{}/README.md 2>/dev/null || eza --tree --color=always --level=2 --icons $(ghq root)/{}")
    
    [[ -n "$selected" ]] && cd "$(ghq root)/$selected"
}

# Zoxide with fzf
zf() {
    local dir
    dir=$(zoxide query -l | fzf --height 40% --reverse --preview "eza --tree --color=always --level=2 --icons {}")
    [[ -n "$dir" ]] && cd "$dir"
}

# ============================================================================
# File Search
# ============================================================================
# Ripgrep with fzf
frg() {
    local result file line
    result=$(rg --line-number --no-heading --color=always --smart-case "${*:-}" |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
    
    if [[ -n "$result" ]]; then
        file=$(echo "$result" | cut -d: -f1)
        line=$(echo "$result" | cut -d: -f2)
        ${EDITOR:-nvim} "$file" +$line
    fi
}

# Open file with preview
fzfv() {
    local file
    file=$(fzf --height 40% --layout=reverse --preview "bat --style=numbers --color=always {}")
    [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# ============================================================================
# Package Management
# ============================================================================
# NPM script runner
fnpm() {
    local script
    if [[ -f package.json ]]; then
        script=$(jq -r '.scripts | keys[]' package.json | fzf --height 40% --reverse --preview "jq -r '.scripts.\"{}\"' package.json")
        
        if [[ -n "$script" ]]; then
            echo "Running: npm run $script"
            npm run "$script"
        fi
    else
        echo "No package.json found in current directory"
    fi
}

# ============================================================================
# Session Management
# ============================================================================
# Tmux session switcher
ftmux() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --height 40% --reverse)
    
    if [[ -n "$session" ]]; then
        if [[ -n "$TMUX" ]]; then
            tmux switch-client -t "$session"
        else
            tmux attach-session -t "$session"
        fi
    fi
}

# ============================================================================
# History
# ============================================================================
# History search
select-history() {
    BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
    CURSOR=$#BUFFER
}

# ============================================================================
# ZLE Widget Registration
# ============================================================================
# Register functions as ZLE widgets where appropriate
zle -N fzf-cdr
zle -N fdgit
zle -N fbr
zle -N fbrr
zle -N select-history

# ============================================================================
# Key Bindings (can be customized in .zshrc)
# ============================================================================
# Default key bindings - can be overridden in .zshrc
bindkey '^f' fzf-cdr
bindkey '^g' fdgit
bindkey '^b' fbr
bindkey '^y^y' fbrr
bindkey '^r' select-history