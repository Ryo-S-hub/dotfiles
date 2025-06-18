#!/usr/bin/env zsh
# ~/.config/zsh/modules/external-tools.zsh - External tool initialization and configuration

# ============================================================================
# FZF Initialization
# ============================================================================
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    # Load fzf-git if available
    [[ -f "${ZSH_MODULES_DIR}/fzf-git.zsh" ]] && source "${ZSH_MODULES_DIR}/fzf-git.zsh"
fi

# ============================================================================
# FZF Custom Functions
# ============================================================================
# Source custom FZF functions if file exists
[[ -f "${ZSH_MODULES_DIR}/fzf-functions.zsh" ]] && source "${ZSH_MODULES_DIR}/fzf-functions.zsh"

# ============================================================================
# Terminal-specific Settings
# ============================================================================
# Auto-start Zellij for Ghostty
if [[ $- == *i* ]] && [[ "$TERM" == "xterm-ghostty" ]]; then
    command -v zellij >/dev/null 2>&1 && eval "$(zellij setup --generate-auto-start zsh)"
fi

# ============================================================================
# Prompt Configuration
# ============================================================================
# Starship prompt (uncomment to enable)
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"