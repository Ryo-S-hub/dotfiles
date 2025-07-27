#!/bin/bash
# GitHub Codespaces dotfiles デバッグ用スクリプト
# Codespacesでdotfilesが実行されない問題を診断します

set -euo pipefail

# カラー出力のための定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

# 環境検出
is_codespaces() {
    [ -n "${CODESPACES:-}" ] && [ "${CODESPACES}" = "true" ]
}

log "=== GitHub Codespaces dotfiles 診断ツール ==="

# 1. 環境情報の確認
log "1. 環境情報の確認"
if is_codespaces; then
    log "✅ GitHub Codespaces環境を検出"
else
    error "❌ GitHub Codespaces環境ではありません"
    exit 1
fi

log "主要環境変数:"
log "  CODESPACES: ${CODESPACES:-未設定}"
log "  GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN: ${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-未設定}"
log "  GITHUB_REPOSITORY: ${GITHUB_REPOSITORY:-未設定}"
log "  GITHUB_USER: ${GITHUB_USER:-未設定}"
log "  HOME: $HOME"
log "  USER: $USER"

# 2. dotfilesディレクトリの検索
log ""
log "2. dotfilesディレクトリの検索"

DOTFILES_CANDIDATES=(
    "$HOME/.dotfiles"
    "/workspaces/.codespaces/.persistedshare/dotfiles"
    "/tmp/.dotfiles"
    "$(pwd)"
)

FOUND_DOTFILES=""
for candidate in "${DOTFILES_CANDIDATES[@]}"; do
    if [ -d "$candidate" ]; then
        log "✅ 発見: $candidate"
        if [ -z "$FOUND_DOTFILES" ]; then
            FOUND_DOTFILES="$candidate"
        fi
        
        # ディレクトリ内容を確認
        log "   内容: $(ls -la "$candidate" 2>/dev/null | head -5)"
        
        # setup スクリプトの確認
        for script in install.sh bootstrap.sh setup.sh; do
            if [ -f "$candidate/$script" ]; then
                log "   ✅ セットアップスクリプト発見: $script"
                if [ -x "$candidate/$script" ]; then
                    log "      実行権限: あり"
                else
                    warning "      実行権限: なし"
                fi
            fi
        done
    else
        log "❌ 未発見: $candidate"
    fi
done

# 3. ディレクトリ構造の確認
log ""
log "3. ディレクトリ構造の確認"
log "現在の作業ディレクトリ: $(pwd)"

if [ -d "/workspaces" ]; then
    log "✅ /workspaces ディレクトリ存在"
    log "   内容: $(ls -la /workspaces 2>/dev/null || echo 'アクセスできません')"
    
    if [ -d "/workspaces/.codespaces" ]; then
        log "✅ /workspaces/.codespaces ディレクトリ存在"
        log "   内容: $(ls -la /workspaces/.codespaces 2>/dev/null || echo 'アクセスできません')"
    else
        warning "❌ /workspaces/.codespaces ディレクトリが存在しません"
    fi
else
    error "❌ /workspaces ディレクトリが存在しません"
fi

# 4. 推奨対策の提示
log ""
log "4. 推奨対策"

if [ -n "$FOUND_DOTFILES" ]; then
    log "✅ dotfilesディレクトリが見つかりました: $FOUND_DOTFILES"
    log "対策: install.sh を直接実行してみてください"
    log "  cd $FOUND_DOTFILES && ./install.sh"
else
    error "❌ dotfilesディレクトリが見つかりません"
    log ""
    log "考えられる原因と対策:"
    log "1. GitHub Settings → Codespaces → 'Automatically install dotfiles' が無効"
    log "   → https://github.com/settings/codespaces でdotfiles設定を確認"
    log ""
    log "2. dotfilesリポジトリのアクセス権限問題（プライベートリポジトリの場合）"
    log "   → リポジトリの設定でCodespacesからのアクセスを許可"
    log ""
    log "3. Codespaces作成後にdotfiles設定を変更した場合"
    log "   → 新しいCodespacesを作成し直す必要があります"
    log ""
    log "4. セットアップスクリプト名の問題"
    log "   → install.sh、bootstrap.sh、setup.sh のいずれかをリポジトリルートに配置"
fi

log ""
log "=== 診断完了 ==="