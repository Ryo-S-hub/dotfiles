#!/usr/bin/env zsh
# ~/.config/zsh/modules/completions.zsh - Completion system and external tool completions

# ============================================================================
# Autoload Functions
# ============================================================================
autoload -Uz colors && colors
autoload -Uz compinit
autoload -Uz bashcompinit && bashcompinit
autoload -Uz history-search-end
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook

# ============================================================================
# Docker CLI completions
# ============================================================================
# Add Docker completions to fpath before compinit
if [[ -d "${HOME}/.docker/completions" ]]; then
    fpath=("${HOME}/.docker/completions" $fpath)
fi

# ============================================================================
# Completion System (optimized initialization)
# ============================================================================
# Check cache age (rebuild if older than a day)
_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"

if [[ -n "$_zcompdump" ]] && [[ -f "$_zcompdump" ]]; then
    # Use cached completion if less than 20 hours old
    if [[ "$_zcompdump" -nt /usr/share/zsh ]] && [[ "$_zcompdump.zwc" -nt "$_zcompdump" ]] && [[ $(date -r "$_zcompdump" +%s) -gt $(( $(date +%s) - 72000 )) ]]; then
        compinit -C
    else
        compinit
        # Compile dump for faster loading
        { [[ -f "$_zcompdump" ]] && zcompile "$_zcompdump" } &!
    fi
else
    compinit
    { [[ -f "$_zcompdump" ]] && zcompile "$_zcompdump" } &!
fi

unset _zcompdump

# ============================================================================
# Zoxide Integration
# ============================================================================
# Zoxide hook
function __zoxide_hook() {
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize zoxide hook
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# Initialize zoxide and set aliases
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='__zoxide_z'
    alias cdi='__zoxide_zi'
fi

# ============================================================================
# CDR Configuration
# ============================================================================
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
fi

# ============================================================================
# External Tool Completions
# ============================================================================
# Google Cloud SDK - now handled with lazy loading in interactive.zsh

# UV (Python package manager) - lazy loading
if command -v uv >/dev/null 2>&1; then
    uv() {
        unfunction uv
        eval "$(command uv generate-shell-completion zsh)"
        uv "$@"
    }
fi

# ============================================================================
# Plugin Management
# ============================================================================
# Zsh autosuggestions (using unified Homebrew check)
if [[ "$ZSH_OFFLINE" != "1" ]] && [[ "$HAS_HOMEBREW" == "1" ]] && [[ -n "$HOMEBREW_PREFIX" ]]; then
    _autosuggestions_file="$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$_autosuggestions_file" ]] && source "$_autosuggestions_file"
    unset _autosuggestions_file
fi