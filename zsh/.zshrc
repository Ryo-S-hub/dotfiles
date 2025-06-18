#!/usr/bin/env zsh
# ~/.config/zsh/.zshrc - Main configuration file (modular)

# ============================================================================
# Performance Optimization
# ============================================================================
# Compile zsh files for faster loading
if [[ -f "${ZDOTDIR:-$HOME}/.zshrc" ]] && [[ ! -f "${ZDOTDIR:-$HOME}/.zshrc.zwc" ]] || [[ "${ZDOTDIR:-$HOME}/.zshrc" -nt "${ZDOTDIR:-$HOME}/.zshrc.zwc" ]]; then
    zcompile "${ZDOTDIR:-$HOME}/.zshrc"
fi

# ============================================================================
# Zsh Options
# ============================================================================
setopt PRINT_EIGHT_BIT          # 日本語ファイル名を表示可能
setopt NO_FLOW_CONTROL          # Ctrl+S/Ctrl+Qを無効化
setopt NO_BEEP                  # ビープ音を無効化
setopt IGNORE_EOF               # Ctrl+Dでログアウトしない

# History
setopt SHARE_HISTORY            # 履歴を共有
setopt INC_APPEND_HISTORY       # 履歴をインクリメンタルに追加
setopt HIST_IGNORE_ALL_DUPS     # 重複を削除
setopt HIST_REDUCE_BLANKS       # 余分な空白を削除
setopt HIST_VERIFY              # 履歴展開の確認
setopt EXTENDED_HISTORY         # 履歴にタイムスタンプを記録

# Directory
setopt AUTO_PUSHD               # cd時に自動でpushd
setopt PUSHD_IGNORE_DUPS        # 重複するディレクトリを追加しない
setopt PUSHD_SILENT             # pushdの出力を抑制

# Completion
setopt AUTO_MENU                # 補完候補を順に表示
setopt COMPLETE_IN_WORD         # 単語の途中でも補完
setopt ALWAYS_TO_END            # 補完後、カーソルを末尾へ
setopt NO_NOMATCH               # グロブがマッチしなくてもエラーにしない

# ============================================================================
# Module Loading
# ============================================================================
# Define the modules directory
ZSH_MODULES_DIR="${XDG_CONFIG_HOME}/zsh/modules"

# Load core modules in order
zsh_modules=(
    "environment"      # Environment variables and paths
    "aliases"         # All aliases
    "functions"       # Custom functions
    "completions"     # Completion system and external completions
    "keybindings"     # Key bindings and ZLE widgets
    "interactive"     # Interactive shell features (SSH, GPG, etc.)
    "external-tools"  # External tool initialization (includes FZF modules)
)
# Load each module
for module in "${zsh_modules[@]}"; do
    module_file="$ZSH_MODULES_DIR/$module.zsh"
    if [[ -f "$module_file" ]]; then
        source "$module_file"
    else
        echo "Warning: Module $module not found at $module_file"
    fi
done

# ============================================================================
# Local Configuration
# ============================================================================
# Source local configuration if exists
[[ -f "${XDG_CONFIG_HOME}/zsh/.zshrc.local" ]] && source "${XDG_CONFIG_HOME}/zsh/.zshrc.local"