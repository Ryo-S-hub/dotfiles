#!/usr/bin/env zsh
# ~/.config/zsh/modules/external-tools.zsh - External tool initialization and configuration

# ============================================================================
# FZF Initialization
# ============================================================================
# FZF デフォルト設定（Ctrl+P/Ctrl+Nで上下移動）
export FZF_DEFAULT_OPTS="--bind 'ctrl-p:up,ctrl-n:down,ctrl-k:up,ctrl-j:down'"

# ============================================================================
# FZF Custom Functions
# ============================================================================
# Source custom FZF functions if file exists
[[ -f "${ZSH_MODULES_DIR}/fzf-functions.zsh" ]] && source "${ZSH_MODULES_DIR}/fzf-functions.zsh"

# ============================================================================
# Terminal-specific Settings
# ============================================================================
# Auto-start Zellij for Ghostty - コメントアウト（tmuxに移行）
# if [[ $- == *i* ]] && [[ "$TERM" == "xterm-ghostty" ]]; then
#     command -v zellij >/dev/null 2>&1 && eval "$(zellij setup --generate-auto-start zsh)"
# fi

# ============================================================================
# Prompt Configuration (Lazy Loading)
# ============================================================================
# Starship prompt (lazy initialization)
if command -v starship >/dev/null 2>&1; then
    { eval "$(starship init zsh)" } &!
fi
