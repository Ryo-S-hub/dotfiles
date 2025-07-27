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
# Completion System (optimized initialization)
# ============================================================================
# Speed up compinit by checking cache once a day
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump" ]]; then
    if [[ "${ZDOTDIR:-$HOME}/.zcompdump" -nt /usr/share/zsh ]] && [[ ! "${ZDOTDIR:-$HOME}/.zcompdump.zwc" -ot "${ZDOTDIR:-$HOME}/.zcompdump" ]]; then
        compinit -C
    else
        compinit
        [[ -f "${ZDOTDIR:-$HOME}/.zcompdump" ]] && zcompile "${ZDOTDIR:-$HOME}/.zcompdump"
    fi
else
    compinit
fi

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
# Google Cloud SDK
[[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

# UV (Python package manager)
command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"

# ============================================================================
# Plugin Management
# ============================================================================
# Zsh autosuggestions
if command -v brew >/dev/null 2>&1 && [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi