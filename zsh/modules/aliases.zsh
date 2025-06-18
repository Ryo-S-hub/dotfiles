#!/usr/bin/env zsh
# ~/.config/zsh/modules/aliases.zsh - All aliases organized by category

# ============================================================================
# Core Aliases
# ============================================================================
# Editor shortcuts
alias vi="nvim"
alias v="nvim"

# Config file shortcuts
alias ve='nvim ~/.config/zsh/.zshenv'
alias vz='nvim ${XDG_CONFIG_HOME}/zsh/.zshrc'
alias vv='nvim ${XDG_CONFIG_HOME}/nvim/init.lua'
alias vg='nvim ${XDG_CONFIG_HOME}/git/config'
alias vt='nvim ${XDG_CONFIG_HOME}/tmux/tmux.conf'
alias vy='nvim ${XDG_CONFIG_HOME}/yazi/yazi.toml'

# VSCode shortcuts
alias codee='code ~/.config/zsh/.zshenv'
alias codez='code ${XDG_CONFIG_HOME}/zsh/.zshrc'
alias codel='code ${XDG_CONFIG_HOME}/nvim/init.lua'
alias codeg='code ${XDG_CONFIG_HOME}/git/config'

# Source shortcuts
alias soe='source ~/.config/zsh/.zshenv'
alias soz='source ${XDG_CONFIG_HOME}/zsh/.zshrc'
alias sot='tmux source-file ${XDG_CONFIG_HOME}/tmux/tmux.conf'

# Directory navigation
alias which-command='whence'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'

# ============================================================================
# Modern CLI Tools (with existence checks)
# ============================================================================
# File listing and navigation
command -v eza >/dev/null 2>&1 && {
    alias ls='eza'
    alias la='eza -a'
    alias ll='eza --header --git --time-style=long-iso -agl'
    alias lt='eza --icons -T -L 2 -a'
    alias tree='eza --icons -T'
}

# Enhanced file operations
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v procs >/dev/null 2>&1 && alias ps='procs'
command -v rg >/dev/null 2>&1 && alias grep='rg'
command -v fd >/dev/null 2>&1 && alias find='fd'

# ============================================================================
# Git Aliases
# ============================================================================
# Basic git commands
alias lg='lazygit'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# git-delta integration
alias gd='git diff | delta'
alias gds='git diff --staged | delta'

# tig integration
alias tigs='tig status'
alias tigb='tig blame'
alias tigh='tig --all'

# GitHub CLI
alias ghr='gh repo'
alias ghp='gh pr'
alias ghi='gh issue'
alias ghw='gh workflow'
alias ghc='gh copilot'

# ============================================================================
# Development Tools
# ============================================================================
# Docker
alias d='docker'
alias dc='docker compose'
alias ld='lazydocker'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'

# Node.js ecosystem
alias pn='pnpm'

# Deno
alias dr='deno run'
alias dt='deno test'
alias df='deno fmt'

# Bun
alias b='bun'
alias br='bun run'
alias bi='bun install'
alias bx='bunx'

# Rust
alias crun='cargo run --quiet'

# Infrastructure
alias t='terraform'
alias k='kubectl'

# ============================================================================
# System Monitoring
# ============================================================================
alias top='procs --watch-interval 1'
alias topc='procs --sortd cpu --watch-interval 1'
alias topm='procs --sortd mem --watch-interval 1'

# ============================================================================
# Session Management
# ============================================================================
alias tm='tmux'
alias tmc='tmux -CC'
alias tmk='tmux kill-server'

# Zellij aliases (if available)
command -v zellij >/dev/null 2>&1 && {
    alias z='zellij'
    alias za='zellij attach'
    alias zl='zellij list-sessions'
    alias zk='zellij kill-session'
}

# ============================================================================
# Interactive Tools
# ============================================================================
alias yz='yazi'
alias c='claude'
alias jnvi='jnv -i'
alias gp='gping'
alias bench='oha'

# ============================================================================
# Other Tools
# ============================================================================
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

# ============================================================================
# Zsh Configuration Inspection
# ============================================================================
alias zshcfg='zsh-config'
alias zshb='zsh-browse'