#!/usr/bin/env zsh
# ~/.config/zsh/.zshenv - Environment variables (loaded for all zsh instances)

# ============================================================================
# XDG Base Directory Specification
# ============================================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/${UID}-runtime-dir}"

# Ensure XDG runtime directory exists
if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    mkdir -m 0700 "$XDG_RUNTIME_DIR"
fi

# ============================================================================
# Zsh Configuration
# ============================================================================
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=100000
export WORDCHARS='*?_-.[]~=!@#$%^(){}<>'

# ============================================================================
# Language and Locale
# ============================================================================
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ============================================================================
# Editor Configuration
# ============================================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="${PAGER:-less}"

# ============================================================================
# Less Configuration
# ============================================================================
export LESS="-R -F -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]"
export LESSCHARSET="utf-8"
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# ============================================================================
# FZF Configuration
# ============================================================================
# Set FZF_BASE based on OS and installation location
if [[ "$OSTYPE" == darwin* ]] && [[ -f "/opt/homebrew/bin/fzf" ]]; then
    export FZF_BASE="/opt/homebrew/bin/fzf"
elif [[ -f "$HOME/.fzf/bin/fzf" ]]; then
    export FZF_BASE="$HOME/.fzf/bin/fzf"
elif command -v fzf >/dev/null 2>&1; then
    export FZF_BASE="$(which fzf)"
fi
export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow --exclude .git --color=always'
# Set clipboard command based on OS
if [[ "$OSTYPE" == darwin* ]]; then
    CLIPBOARD_CMD="pbcopy"
elif command -v xclip >/dev/null 2>&1; then
    CLIPBOARD_CMD="xclip -selection clipboard"
elif command -v wl-copy >/dev/null 2>&1; then
    CLIPBOARD_CMD="wl-copy"
else
    CLIPBOARD_CMD="cat"  # fallback
fi

export FZF_DEFAULT_OPTS="
  --ansi
  --height 40%
  --layout=reverse
  --border
  --inline-info
  --bind=\"ctrl-y:execute-silent(echo -n {2..} | $CLIPBOARD_CMD)+abort\"
  --bind=\"ctrl-d:half-page-down\"
  --bind=\"ctrl-u:half-page-up\"
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always --line-range=:500 {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
"

export FZF_ALT_C_COMMAND='fd --type directory --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | $CLIPBOARD_CMD)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'
"

# ============================================================================
# Development Tools
# ============================================================================
# Rust
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
export RUST_BACKTRACE=1

# Node.js
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"

# Go
export GOPATH="${GOPATH:-$HOME/go}"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"

# Deno
export DENO_DIR="$XDG_CACHE_HOME/deno"

# Python
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

# Java
if [[ -x "/usr/libexec/java_home" ]]; then
    export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null)
fi

# GPG
export GPG_TTY=$(tty)

# ============================================================================
# Tool Configurations
# ============================================================================
# Zoxide
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"

# Yazi
export YAZI_CONFIG_HOME="$XDG_CONFIG_HOME/yazi"

# Tig
export TIGRC_USER="$XDG_CONFIG_HOME/tig/tigrc"

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# ============================================================================
# macOS Specific
# ============================================================================
if [[ "$OSTYPE" == darwin* ]]; then
  # Homebrew
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
  
  # OpenSSL
  export OPENSSL_X509_TEA_DISABLE=1
fi

# ============================================================================
# PATH Configuration
# ============================================================================
# Function to add to PATH (prevents duplicates)
path_prepend() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

path_append() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) export PATH="$PATH:$1" ;;
  esac
}

# System paths (usually already set)
path_prepend "/usr/local/bin"
path_prepend "/opt/homebrew/bin"
path_prepend "/opt/homebrew/sbin"

# Development tools
path_prepend "$CARGO_HOME/bin"
path_prepend "$GOPATH/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$PYENV_ROOT/bin"

# Node.js tools
if [[ -d "$HOME/.nodebrew/current/bin" ]]; then
  path_prepend "$HOME/.nodebrew/current/bin"
fi

# pnpm
if [[ -d "$HOME/Library/pnpm" ]]; then
  path_prepend "$HOME/Library/pnpm"
fi

# Deno
if [[ -d "$HOME/.deno/bin" ]]; then
  path_prepend "$HOME/.deno/bin"
fi

# Google Cloud SDK
if [[ -d "$HOME/google-cloud-sdk/bin" ]]; then
  path_append "$HOME/google-cloud-sdk/bin"
fi

# JetBrains Toolbox
if [[ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
  path_append "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# ============================================================================
# Security - Handle sensitive files carefully
# ============================================================================
# Only set if the file exists and has proper permissions
if [[ -f "$HOME/kiiromamert-430d54897a92.json" ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS="$HOME/kiiromamert-430d54897a92.json"
fi

# ============================================================================
# Cleanup
# ============================================================================
unfunction path_prepend path_append