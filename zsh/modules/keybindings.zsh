#!/usr/bin/env zsh
# ~/.config/zsh/modules/keybindings.zsh - Key bindings and ZLE widgets

# ============================================================================
# Basic Key Bindings
# ============================================================================
bindkey -e  # Emacs keybindings

# History search with arrow keys (no conflict with Ctrl+P/N)
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end  # Up arrow
bindkey "^[[B" history-beginning-search-forward-end   # Down arrow

# ============================================================================
# FZF Key Bindings and Functions
# ============================================================================
# CD to recent directory
function fzf-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse --preview 'eza --tree --color=always --level=2 --icons {}' --bind 'ctrl-p:up,ctrl-n:down')
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-cdr
bindkey '^[f' fzf-cdr  # Alt+f for directory search

# Git directory navigation
function fdgit() {
    local top_dir dir
    top_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ -z "$top_dir" ]; then
        echo "Not in a Git repository."
        return 1
    fi
    
    dir="$(cd "$top_dir" || return 1; fd --type d --exclude .git | fzf --preview 'eza --tree --color=always --level=2 --icons {}' --bind 'ctrl-p:up,ctrl-n:down')"
    [ -n "$dir" ] && cd "$top_dir/$dir"
}
zle -N fdgit
bindkey '^[g' fdgit  # Alt+g for git directory navigation

# History search
function select-history() {
    BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > " --bind 'ctrl-p:up,ctrl-n:down')
    CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^[r' select-history  # Alt+r for history search


# ============================================================================
# Additional FZF Widgets (if fzf-functions.zsh is loaded)
# ============================================================================
# These will be registered if the fzf-functions.zsh module is loaded
# - fbr (git branch checkout)
# - fbrr (git remote branch checkout)
# - Various other FZF functions

# Note: Key bindings for functions from fzf-functions.zsh are set there