#!/usr/bin/env zsh
# ~/.config/zsh/modules/functions.zsh - Custom functions and utilities

# ============================================================================
# Core Functions
# ============================================================================
# Yazi with cwd change
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Change directory and list (with performance optimization)
function chpwd() {
    # HOMEディレクトリでは実行しない
    if [[ $(pwd) == $HOME ]]; then
        return
    fi
    
    # 大きなディレクトリではスキップ（ファイル数が100以上）
    local file_count=$(ls -1 | wc -l 2>/dev/null)
    if [[ $file_count -gt 100 ]]; then
        echo "📁 $(pwd) (${file_count} items - listing skipped for performance)"
        return
    fi
    
    # ezaが利用可能な場合のみ実行
    if command -v eza >/dev/null 2>&1; then
        eza -A
    else
        ls -la
    fi
}

# tre-command with aliases
tre() { 
    command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null
}

# 最近のファイルを素早く開く
r() {
  local file
  file=$(fd --type f --changed-within 7d | fzf --preview 'bat --color=always {}')
  [ -n "$file" ] && nvim "$file"
}

# ============================================================================
# Git Functions
# ============================================================================
# GitHub CLI with FZF
ghpr() {
    local pr
    pr=$(gh pr list --limit 100 | fzf --preview 'gh pr view {1} --comments' | awk '{print $1}')
    [ -n "$pr" ] && gh pr checkout "$pr"
}

ghis() {
    local issue
    issue=$(gh issue list --limit 100 | fzf --preview 'gh issue view {1}' | awk '{print $1}')
    [ -n "$issue" ] && gh issue view "$issue" --web
}

# ============================================================================
# Development Functions
# ============================================================================
# Interactive JSON viewer
fjson() {
    local file
    file=$(fd -e json | fzf --preview 'bat --color=always {}')
    [ -n "$file" ] && jnv "$file"
}

# Terraform workspace switcher
tfw() {
    local workspace
    workspace=$(terraform workspace list | sed 's/^[* ] //' | fzf)
    [ -n "$workspace" ] && terraform workspace select "$workspace"
}

# Bun script runner
fbun() {
    local script
    if [ -f package.json ]; then
        script=$(jq -r '.scripts | keys[]' package.json | fzf --preview "jq -r '.scripts.\"{}\"' package.json")
        [ -n "$script" ] && bun run "$script"
    else
        echo "No package.json found"
    fi
}

# Deno task runner
fdeno() {
    if [ -f deno.json ] || [ -f deno.jsonc ]; then
        local config_file
        [ -f deno.json ] && config_file="deno.json" || config_file="deno.jsonc"
        local task=$(jq -r '.tasks | keys[]' "$config_file" 2>/dev/null | fzf --preview "jq -r '.tasks.\"{}\"' $config_file")
        [ -n "$task" ] && deno task "$task"
    else
        echo "No deno.json(c) found"
    fi
}

# ============================================================================
# System Functions
# ============================================================================
# Watchman integration
wrun() {
    if [ $# -lt 2 ]; then
        echo "Usage: watch-run <pattern> <command>"
        return 1
    fi
    watchman-make -p "$1" --run "$2"
}

# ログ監視（複数ツール組み合わせ）
wlog() {
  local logfile
  logfile=$(fd -e log | fzf)
  [ -n "$logfile" ] && bat "$logfile" && watchman-make -p "$logfile" --run "bat $logfile"
}

# API benchmarking
bench-api() {
    if [ $# -lt 1 ]; then
        echo "Usage: bench-api <url> [options]"
        return 1
    fi
    oha -n 1000 -c 10 --latency-correction "$@"
}

# W3M Google search
google() {
    if [ $# -eq 0 ]; then
        echo "Usage: google <search terms>"
        return 1
    fi
    local query=$(echo "$@" | tr ' ' '+')
    w3m "https://www.google.com/search?q=$query"
}

# System info
sysinfo() {
    echo "=== System Info ==="
    echo "CPU Usage:"
    procs --no-header --only pid,cpu,name | head -5
    echo "\nMemory Usage:"
    procs --no-header --only pid,mem,name --sortd mem | head -5
    echo "\nDisk Usage:"
    df -h | grep -E '^/dev/'
}

# ============================================================================
# Session Management Functions
# ============================================================================

# プロジェクトベースのzellij セッション作成/接続
# ============================================================================
# Zellij Functions (Autoloaded)
# ============================================================================
# Zellij関数は zellij-functions.zsh からautoloadで読み込まれます
# 利用可能な関数: zj, zjdev, zjwork, zjp, zjclean, zjs, zjcreate



# ============================================================================
# Zsh Configuration Inspection Functions
# ============================================================================
# List all aliases with optional filtering
list-aliases() {
    local filter="${1:-}"
    echo "=== Zsh Aliases ==="
    echo
    if [ -n "$filter" ]; then
        alias | grep -i "$filter" | sort | sed 's/^/  /'
    else
        alias | sort | sed 's/^/  /'
    fi
}

# List all functions with optional filtering
list-functions() {
    local filter="${1:-}"
    echo "=== Zsh Functions ==="
    echo
    if [ -n "$filter" ]; then
        print -l ${(ok)functions} | grep -i "$filter" | while read func; do
            echo "  $func"
        done
    else
        print -l ${(ok)functions} | while read func; do
            echo "  $func"
        done
    fi
}

# Show all custom aliases and functions
zsh-config() {
    local option="${1:-all}"
    
    case "$option" in
        alias|aliases)
            list-aliases "${2:-}"
            ;;
        func|functions)
            list-functions "${2:-}"
            ;;
        all)
            list-aliases
            echo
            list-functions
            ;;
        help)
            echo "Usage: zsh-config [option] [filter]"
            echo
            echo "Options:"
            echo "  all           - Show all aliases and functions (default)"
            echo "  alias/aliases - Show only aliases"
            echo "  func/functions - Show only functions"
            echo "  help          - Show this help message"
            echo
            echo "Filter:"
            echo "  Optional text to filter results (case-insensitive)"
            echo
            echo "Examples:"
            echo "  zsh-config              # Show all aliases and functions"
            echo "  zsh-config alias git    # Show only git-related aliases"
            echo "  zsh-config func fzf     # Show only fzf-related functions"
            ;;
        *)
            echo "Unknown option: $option"
            echo "Use 'zsh-config help' for usage information"
            return 1
            ;;
    esac
}

# Interactive alias/function browser with fzf
zb() {
    local selection category item
    
    # Create temporary file with all aliases and functions
    local tmpfile=$(mktemp)
    
    # Add aliases
    alias | while IFS='=' read -r name value; do
        echo "ALIAS: $name = $value" >> "$tmpfile"
    done
    
    # Add functions
    print -l ${(ok)functions} | while read func; do
        # Skip completion functions and internal functions
        if [[ ! "$func" =~ ^(_|comp) ]]; then
            echo "FUNCTION: $func" >> "$tmpfile"
        fi
    done
    
    # Use fzf to browse
    selection=$(cat "$tmpfile" | fzf --preview-window=right:60%:wrap --preview '
        if [[ {} =~ ^ALIAS:\ (.*)\ =\ (.*)$ ]]; then
            echo "Type: Alias"
            echo "Name: ${match[1]}"
            echo "Definition: ${match[2]}"
        elif [[ {} =~ ^FUNCTION:\ (.*)$ ]]; then
            echo "Type: Function"
            echo "Name: ${match[1]}"
            echo ""
            echo "Definition:"
            whence -f "${match[1]}" 2>/dev/null | tail -n +2
        fi
    ')
    
    rm -f "$tmpfile"
    
    # Execute or display the selected item
    if [ -n "$selection" ]; then
        if [[ "$selection" =~ ^ALIAS:\ (.*)\ =\ (.*)$ ]]; then
            echo "Selected alias: ${match[1]}"
            echo "Executes: ${match[2]}"
        elif [[ "$selection" =~ ^FUNCTION:\ (.*)$ ]]; then
            echo "Selected function: ${match[1]}"
            echo "Use '${match[1]}' to execute"
        fi
    fi
}

# プロジェクト切り替え（zoxide + fzf + zellij）
proj() {
  local project
  project=$(fd -t d -d 3 . ~/workspace | fzf)
  if [ -n "$project" ]; then
    cd "$project"
    local session_name="$(basename "$project")"
    
    # zellij セッション作成または接続
    if command -v zellij &> /dev/null; then
      # 既存セッションがあるかチェック
      if zellij list-sessions 2>/dev/null | grep -q "^$session_name\s"; then
        echo "Attaching to existing session: $session_name"
        zellij attach "$session_name"
      else
        echo "Creating new session: $session_name"
        zellij attach -c "$session_name"
      fi
    else
      echo "zellij not found"
    fi
  fi
}


# より高機能なプロジェクト切り替え（zellij版）
projz() {
  local project
  project=$(fd -t d -d 3 . ~/workspace | fzf --preview 'eza -la {} | head -10')
  if [ -n "$project" ]; then
    cd "$project"
    local session_name="$(basename "$project")"
    
    # プロジェクトタイプを検出
    local project_type=""
    if [ -f "package.json" ]; then
      project_type="node"
    elif [ -f "Cargo.toml" ]; then
      project_type="rust"
    elif [ -f "go.mod" ]; then
      project_type="go"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
      project_type="python"
    fi
    
    # zellij起動
    if command -v zellij &> /dev/null; then
      if zellij list-sessions 2>/dev/null | grep -q "^$session_name\s"; then
        echo "Attaching to existing session: $session_name ($project_type project)"
        zellij attach "$session_name"
      else
        echo "Creating new session: $session_name ($project_type project)"
        # プロジェクトタイプ別の初期化
        case "$project_type" in
          "node"|"rust"|"go"|"python")
            # 開発用レイアウトがあれば使用
            if [ -f "$HOME/.config/zellij/layouts/dev.kdl" ]; then
                zellij attach -c "$session_name" --layout "$HOME/.config/zellij/layouts/dev.kdl"
            else
                zellij attach -c "$session_name"
            fi
            ;;
          *)
            zellij attach -c "$session_name"
            ;;
        esac
      fi
    else
      echo "zellij not found"
    fi
  fi
}


# 最近のプロジェクトから選択（zellij版）
projr() {
  local project
  # zoxideの履歴から~/projects配下のディレクトリを取得
  project=$(zoxide query -l | grep -E "^$HOME/workspace" | fzf --preview 'eza -la {} | head -10')
  if [ -n "$project" ]; then
    cd "$project"
    local session_name="$(basename "$project")"
    
    if command -v zellij &> /dev/null; then
      if zellij list-sessions 2>/dev/null | grep -q "^$session_name\s"; then
        zellij attach "$session_name"
      else
        zellij attach -c "$session_name"
      fi
    fi
  fi
}


# 開発ワークフロー（zellij版）
work() {
  echo "🚀 Starting development workflow..."
  
  # 1. プロジェクトディレクトリに移動
  echo "📁 Select project..."
  projz
  
  # zellijセッション内でのファイル操作は手動で行う
  # （zellijは既に起動しているため）
  echo "💡 Use 'fe' to edit files and 'lg' for git operations"
}


