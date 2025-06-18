#!/usr/bin/env zsh
# ~/.config/zsh/modules/keybindings.zsh - Key bindings and ZLE widgets

# ============================================================================
# Basic Key Bindings
# ============================================================================
bindkey -e  # Emacs keybindings

# History search
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# ============================================================================
# FZF Key Bindings and Functions
# ============================================================================
# CD to recent directory
function fzf-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse --preview 'eza --tree --color=always --level=2 --icons {}')
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-cdr
bindkey '^f' fzf-cdr

# Git directory navigation
function fdgit() {
    local top_dir dir
    top_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ -z "$top_dir" ]; then
        echo "Not in a Git repository."
        return 1
    fi
    
    dir="$(cd "$top_dir" || return 1; fd --type d --exclude .git | fzf --preview 'eza --tree --color=always --level=2 --icons {}')"
    [ -n "$dir" ] && cd "$top_dir/$dir"
}
zle -N fdgit
bindkey '^g' fdgit

# History search
function select-history() {
    BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
    CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

# ============================================================================
# Additional FZF Widgets (if fzf-functions.zsh is loaded)
# ============================================================================
# These will be registered if the fzf-functions.zsh module is loaded
# - fbr (git branch checkout)
# - fbrr (git remote branch checkout)
# - Various other FZF functions

# Note: Key bindings for functions from fzf-functions.zsh are set there