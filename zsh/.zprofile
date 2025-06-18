#!/usr/bin/env zsh
# ~/.config/zsh/.zprofile - Login shell configuration
# Executed for login shells after .zshenv but before .zshrc

# ============================================================================
# macOS Specific Settings
# ============================================================================
if [[ "$OSTYPE" == darwin* ]]; then
    # Homebrew initialization (Apple Silicon)
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    # Homebrew initialization (Intel)
    if [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Language and locale are already set in .zshenv

# SSH Agent initialization moved to .zshrc (only needed for interactive shells)

# GPG configuration moved to .zshenv and .zshrc

# ============================================================================
# Development Environment Initialization
# ============================================================================
# Initialize Rust environment
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# Initialize Google Cloud SDK
if [[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# Google Cloud SDK completion moved to .zshrc

# Initialize Node Version Manager (if using nvm instead of nodebrew)
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Initialize pyenv (path already set in .zshenv)
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
fi

# rbenv initialization moved to .zshrc (interactive shell feature)

# Java environment variables moved to .zshenv

# Terminal initialization moved to .zshrc (interactive feature)

# ============================================================================
# Security Settings
# ============================================================================
# Set secure umask
umask 022

# Disable core dumps
ulimit -c 0

# ============================================================================
# System Resources
# ============================================================================
# Increase open file limit for development
ulimit -n 8192

# ============================================================================
# Temporary Directory
# ============================================================================
# Ensure XDG runtime directory exists
if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    export XDG_RUNTIME_DIR="/tmp/${UID}-runtime-dir"
    if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
        mkdir -m 0700 "$XDG_RUNTIME_DIR"
    fi
fi

# ============================================================================
# macOS Specific Development Settings
# ============================================================================
if [[ "$OSTYPE" == darwin* ]]; then
    # Silence macOS zsh warning about bash being the default
    export BASH_SILENCE_DEPRECATION_WARNING=1
    
    # Add macOS specific paths
    if [[ -d "/Applications/Postgres.app/Contents/Versions/latest/bin" ]]; then
        export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"
    fi
    
    # Docker Desktop for Mac
    if [[ -d "/Applications/Docker.app/Contents/Resources/bin" ]]; then
        export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
    fi
fi

# ============================================================================
# Custom Scripts Directory
# ============================================================================
if [[ -d "$HOME/.local/scripts" ]]; then
    export PATH="$HOME/.local/scripts:$PATH"
fi

# Completion system initialization moved to .zshrc

# Login message display moved to .zshrc