#!/usr/bin/env zsh
# ~/.config/zsh/modules/environment.zsh - Additional environment configurations

# ============================================================================
# Environment Detection
# ============================================================================
export OS_TYPE="$(uname -s)"
export TERM_PROGRAM="${TERM_PROGRAM:-$TERM}"

# ============================================================================
# Network/Performance Settings
# ============================================================================
# オフラインモード (ZSH_OFFLINE=1 で有効)
# ネットワーク接続を必要とする機能を無効化
export ZSH_OFFLINE="${ZSH_OFFLINE:-0}"

# Homebrew存在確認の一元化
if command -v brew >/dev/null 2>&1; then
    export HAS_HOMEBREW=1
    # Homebrewパスの効率的な設定
    if [[ -z "$HOMEBREW_PREFIX" ]]; then
        if [[ -d "/opt/homebrew" ]]; then
            export HOMEBREW_PREFIX="/opt/homebrew"
        elif [[ -d "/usr/local/Homebrew" ]]; then
            export HOMEBREW_PREFIX="/usr/local"
        else
            [[ "$ZSH_OFFLINE" != "1" ]] && export HOMEBREW_PREFIX="$(brew --prefix)"
        fi
    fi
else
    export HAS_HOMEBREW=0
fi

# ============================================================================
# Development Environment Variables (not in .zshenv)
# ============================================================================
# Git delta
export DELTA_FEATURES="+side-by-side +line-numbers +decorations"
export GIT_PAGER="delta"

# Development paths
export GHQ_ROOT="$HOME/dev"
export GOBIN="$GOPATH/bin"
export UV_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/uv"
export DENO_INSTALL="$HOME/.deno"
export PNPM_HOME="$HOME/Library/pnpm"

# ============================================================================
# Interactive Shell Configuration
# ============================================================================
# Create necessary directories
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d "$XDG_DATA_HOME/zsh" ]] || mkdir -p "$XDG_DATA_HOME/zsh"

# ============================================================================
# Additional Tool Configurations
# ============================================================================
# Bat configuration
export BAT_THEME="TwoDark"
export BAT_STYLE="numbers,changes,header"

# Ripgrep configuration
# export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# Claude CLI
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/.claude"

# Man pages with bat
if command -v bat >/dev/null 2>&1; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

# ============================================================================
# Security
# ============================================================================
# Homebrew security
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS="--require-sha"

# ============================================================================
# Performance
# ============================================================================
# Disable automatic updates during brew commands
export HOMEBREW_NO_AUTO_UPDATE=1

# Enable parallel compilation
if [[ "$OSTYPE" == darwin* ]]; then
    # macOSの場合
    export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"
else
    # Linuxの場合
    export MAKEFLAGS="-j$(nproc)"
fi

# ============================================================================
# Locale Settings for Interactive Shells
# ============================================================================
# Set collation for better sorting
export LC_COLLATE="C"
export LC_NUMERIC="C"
export LC_TIME="en_US.UTF-8"

# ============================================================================
# GCP Configuration
# ============================================================================
# read .env file
if [[ -f "$HOME/.config/zsh/modules/.env" ]]; then
    export $(grep -v '^#' "$HOME/.config/zsh/modules/.env" | xargs)
fi

