#!/bin/bash
# Universal dotfiles setup script for macOS, Ubuntu, and GitHub Codespaces
# このスクリプトは新しい環境でdotfilesをセットアップするために使用します

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

# =============================================================================
# 環境検出
# =============================================================================
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *) echo "unknown" ;;
    esac
}

is_codespaces() {
    [ -n "${CODESPACES:-}" ] && [ "${CODESPACES}" = "true" ]
}

# Codespaces環境の詳細情報をデバッグ出力
debug_codespaces_environment() {
    if is_codespaces; then
        log "=== Codespaces環境デバッグ情報 ==="
        log "主要環境変数:"
        log "  CODESPACES: ${CODESPACES:-未設定}"
        log "  GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN: ${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-未設定}"
        log "  GITHUB_REPOSITORY: ${GITHUB_REPOSITORY:-未設定}"
        log "  GITHUB_USER: ${GITHUB_USER:-未設定}"
        log ""
        log "ディレクトリ構造:"
        log "  HOME: $HOME"
        log "  PWD: $(pwd)"
        log "  /workspaces: $(ls -la /workspaces 2>/dev/null || echo '存在しません')"
        if [ -d "/workspaces/.codespaces" ]; then
            log "  /workspaces/.codespaces: $(ls -la /workspaces/.codespaces 2>/dev/null || echo 'アクセスできません')"
        fi
        log "================================"
    fi
}

is_vscode_server() {
    [ -n "${VSCODE_IPC_HOOK_CLI:-}" ] || [ -n "${VSCODE_GIT_ASKPASS_NODE:-}" ] || [ -d "/workspaces" ]
}

is_remote_container() {
    [ -f "/.dockerenv" ] || [ -n "${REMOTE_CONTAINERS:-}" ]
}

OS=$(detect_os)
ARCH=$(detect_arch)

# メイン処理の開始
log "Universal dotfiles セットアップを開始します..."
log "OS: $OS"
log "Architecture: $ARCH"
if is_codespaces; then
    log "Environment: GitHub Codespaces"
    log "詳細環境情報:"
    log "  CODESPACES: ${CODESPACES:-未設定}"
    log "  GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN: ${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-未設定}"
    log "  GITHUB_REPOSITORY: ${GITHUB_REPOSITORY:-未設定}"
    log "  VSCODE_GIT_ASKPASS_NODE: ${VSCODE_GIT_ASKPASS_NODE:-未設定}"
elif is_vscode_server; then
    log "Environment: VS Code Server"
elif is_remote_container; then
    log "Environment: Remote Container"
else
    log "Environment: Local"
fi

# ユーザー情報の取得
if [ -z "${USER:-}" ]; then
    USER=$(id -un)
fi

log "ユーザー: $USER"
log "ホームディレクトリ: $HOME"

# Codespaces環境のデバッグ情報を出力
debug_codespaces_environment

# dotfilesのパス設定
if is_codespaces; then
    # Codespacesの場合：複数の候補パスを試行
    DOTFILES_CANDIDATES=(
        "$HOME/.dotfiles"
        "/workspaces/.codespaces/.persistedshare/dotfiles"
        "/tmp/.dotfiles"
        "$(pwd)"
    )
    
    DOTFILES_SOURCE=""
    for candidate in "${DOTFILES_CANDIDATES[@]}"; do
        log "dotfilesパス候補をチェック中: $candidate"
        if [ -d "$candidate" ]; then
            DOTFILES_SOURCE="$candidate"
            log "dotfilesパスを発見: $DOTFILES_SOURCE"
            break
        fi
    done
    
    if [ -z "$DOTFILES_SOURCE" ]; then
        error "Codespacesでdotfilesディレクトリが見つかりません"
        log "チェックした候補パス:"
        for candidate in "${DOTFILES_CANDIDATES[@]}"; do
            log "  - $candidate"
        done
        log "環境変数の確認:"
        log "  CODESPACES: ${CODESPACES:-未設定}"
        log "  HOME: $HOME"
        log "  PWD: $(pwd)"
        exit 1
    fi
else
    # ローカル環境の場合（スクリプトが実行されているディレクトリ）
    DOTFILES_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

DOTFILES_TARGET="$HOME/.config"

# dotfilesが正しい場所にあるか最終確認（フォールバック後）
if [ ! -d "$DOTFILES_SOURCE" ]; then
    error "dotfilesディレクトリが見つかりません: $DOTFILES_SOURCE"
    if is_codespaces; then
        error "Codespacesで dotfiles が正しく設定されていない可能性があります。"
        error ""
        error "トラブルシューティング:"
        error "1. GitHub Settings → Codespaces → 'Automatically install dotfiles' が有効か確認"
        error "2. dotfilesリポジトリがプライベートの場合、Codespacesからのアクセス権限を確認"
        error "3. Codespaces作成後にdotfiles設定を変更した場合、新しいCodespacesを作成する必要があります"
        error "4. install.sh、bootstrap.sh、setup.sh のいずれかがリポジトリのルートにあることを確認"
        error ""
        error "現在の環境:"
        error "  作業ディレクトリ: $(pwd)"
        error "  存在するファイル: $(ls -la)"
    fi
    exit 1
fi

log "dotfilesソース: $DOTFILES_SOURCE"

# .configディレクトリの作成
mkdir -p "$HOME/.config"

# =============================================================================
# OS別のパッケージマネージャーセットアップ
# =============================================================================
install_packages() {
    case "$OS" in
        macos)
            install_macos_packages
            ;;
        linux)
            install_linux_packages
            ;;
        *)
            error "サポートされていないOS: $OS"
            exit 1
            ;;
    esac
}

# =============================================================================
# macOS用のパッケージインストール
# =============================================================================
install_macos_packages() {
    log "macOS用のパッケージをインストールしています..."
    
    # Homebrewのインストール
    if ! command -v brew &> /dev/null; then
        log "Homebrewをインストールしています..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Homebrewのパス設定（Apple Silicon対応）
        if [ "$ARCH" = "arm64" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    log "Homebrewパッケージをインストールしています..."
    
    # Brewfileが存在する場合は、Brewfileからインストール
    if [ -f "$DOTFILES_TARGET/Brewfile" ]; then
        log "Brewfileからパッケージをインストールしています..."
        brew bundle install --file="$DOTFILES_TARGET/Brewfile" || true
    else
        # Brewfileがない場合は最小限のパッケージをインストール
        log "基本的なパッケージをインストールしています..."
        
        # 基本的なツール
        brew install \
            curl \
            wget \
            git \
            jq \
            htop \
            tree \
            tmux \
            zsh \
            python3 || true
        
        # 開発ツール
        brew install \
            neovim \
            ripgrep \
            fd \
            fzf \
            bat \
            eza \
            lazygit \
            zoxide \
            gh || true
        
        # fnm (Fast Node Manager)
        brew install fnm || true
    fi
    
    # fzfのキーバインディングをインストール
    if command -v fzf &> /dev/null; then
        $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish || true
    fi
}

# =============================================================================
# Linux/Ubuntu用のパッケージインストール
# =============================================================================
install_linux_packages() {
    log "Linux用のパッケージをインストールしています..."
    
    # 一時的にsudoパスワードなしで実行できるようにする（リモート環境用）
    if is_codespaces || is_vscode_server || is_remote_container; then
        export SUDO_ASKPASS=/bin/true
        export DEBIAN_FRONTEND=noninteractive
    fi
    
    # システムパッケージの更新
    log "システムパッケージを更新しています..."
    if ! sudo apt-get update -qq; then
        warning "パッケージリストの更新に失敗しました。ネットワーク接続を確認してください。"
        # 一定時間待ってリトライ
        sleep 5
        sudo apt-get update -qq || {
            error "パッケージリストの更新に失敗しました。インストールを続行できません。"
            exit 1
        }
    fi
    
    log "基本的なパッケージをインストールしています..."
    
    # 基本パッケージ（軽量化）
    if is_codespaces || is_vscode_server; then
        # Codespaces/VS Code Server用の軽量パッケージセット
        sudo apt-get install -y -qq \
            curl \
            wget \
            git \
            unzip \
            jq \
            tree \
            zsh \
            python3-pip || true
    else
        # フル機能パッケージセット
        sudo apt-get install -y -qq \
            curl \
            wget \
            git \
            build-essential \
            software-properties-common \
            apt-transport-https \
            ca-certificates \
            gnupg \
            lsb-release \
            unzip \
            jq \
            htop \
            tree \
            tmux \
            zsh \
            python3-pip \
            python3-venv || true
    fi
    
    # Neovimのインストール
    if ! command -v nvim &> /dev/null; then
        log "Neovimをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            # 正しいURLでNeovimをダウンロード
            if curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | \
                sudo tar -C /opt -xzf - && \
                sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim; then
                log "Neovimのインストールが完了しました"
            else
                warning "Neovimのダウンロードに失敗しました。aptからインストールを試行します..."
                sudo apt-get install -y neovim || warning "Neovimのインストールに失敗しました"
            fi
        else
            # ARM64の場合はaptから
            sudo apt-get install -y neovim || warning "Neovimのインストールに失敗しました"
        fi
    fi
    
    # ripgrepのインストール
    if ! command -v rg &> /dev/null; then
        log "ripgrepをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            # GitHub APIから最新バージョンを取得し、より安定した解析を行う
            if RIPGREP_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name' 2>/dev/null) && \
               [ -n "$RIPGREP_VERSION" ] && [ "$RIPGREP_VERSION" != "null" ]; then
                # バージョンからvプレフィックスを除去
                VERSION_NUMBER="${RIPGREP_VERSION#v}"
                # ripgrepの.debファイルには-1サフィックスが付く
                DOWNLOAD_URL="https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep_${VERSION_NUMBER}-1_amd64.deb"
                log "ripgrep ${RIPGREP_VERSION} をダウンロードしています..."
                
                if curl -fsSL "$DOWNLOAD_URL" -o /tmp/ripgrep.deb && \
                   sudo dpkg -i /tmp/ripgrep.deb; then
                    rm -f /tmp/ripgrep.deb
                    log "ripgrepのインストールが完了しました"
                else
                    rm -f /tmp/ripgrep.deb
                    warning "ripgrepのダウンロードに失敗しました（URL: $DOWNLOAD_URL）。aptからインストールを試行します..."
                    sudo apt-get install -y ripgrep || warning "ripgrepのインストールに失敗しました"
                fi
            else
                warning "ripgrepのバージョン情報取得に失敗しました。aptからインストールを試行します..."
                sudo apt-get install -y ripgrep || warning "ripgrepのインストールに失敗しました"
            fi
        else
            sudo apt-get install -y ripgrep || warning "ripgrepのインストールに失敗しました"
        fi
    fi
    
    # fd-findのインストール
    if ! command -v fd &> /dev/null; then
        log "fd-findをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            # GitHub APIから最新バージョンを取得し、より安定した解析を行う
            if FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name' 2>/dev/null) && \
               [ -n "$FD_VERSION" ] && [ "$FD_VERSION" != "null" ]; then
                # バージョンからvプレフィックスを除去
                VERSION_NUMBER="${FD_VERSION#v}"
                DOWNLOAD_URL="https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd_${VERSION_NUMBER}_amd64.deb"
                log "fd-find ${FD_VERSION} をダウンロードしています..."
                
                if curl -fsSL "$DOWNLOAD_URL" -o /tmp/fd.deb && \
                   sudo dpkg -i /tmp/fd.deb; then
                    rm -f /tmp/fd.deb
                    log "fd-findのインストールが完了しました"
                else
                    rm -f /tmp/fd.deb
                    warning "fd-findのダウンロードに失敗しました（URL: $DOWNLOAD_URL）。aptからインストールを試行します..."
                    sudo apt-get install -y fd-find && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd || warning "fd-findのインストールに失敗しました"
                fi
            else
                warning "fd-findのバージョン情報取得に失敗しました。aptからインストールを試行します..."
                sudo apt-get install -y fd-find && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd || warning "fd-findのインストールに失敗しました"
            fi
        else
            if sudo apt-get install -y fd-find; then
                sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd || true
            else
                warning "fd-findのインストールに失敗しました"
            fi
        fi
    fi
    
    # fzfのインストール
    if ! command -v fzf &> /dev/null; then
        log "fzfをインストールしています..."
        if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
           ~/.fzf/install --all --no-bash --no-fish; then
            # PATHに追加（現在のセッション用）
            export PATH="$HOME/.fzf/bin:$PATH"
            log "fzfのインストールが完了しました"
        else
            warning "fzfのインストールに失敗しました"
        fi
    fi
    
    # batのインストール
    if ! command -v bat &> /dev/null; then
        log "batをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            # GitHub APIから最新バージョンを取得し、より安定した解析を行う
            if BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.tag_name' 2>/dev/null) && \
               [ -n "$BAT_VERSION" ] && [ "$BAT_VERSION" != "null" ]; then
                # バージョンからvプレフィックスを除去
                VERSION_NUMBER="${BAT_VERSION#v}"
                DOWNLOAD_URL="https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${VERSION_NUMBER}_amd64.deb"
                log "bat ${BAT_VERSION} をダウンロードしています..."
                
                if curl -fsSL "$DOWNLOAD_URL" -o /tmp/bat.deb && \
                   sudo dpkg -i /tmp/bat.deb; then
                    rm -f /tmp/bat.deb
                    log "batのインストールが完了しました"
                else
                    rm -f /tmp/bat.deb
                    warning "batのダウンロードに失敗しました（URL: $DOWNLOAD_URL）。aptからインストールを試行します..."
                    sudo apt-get install -y bat || warning "batのインストールに失敗しました"
                fi
            else
                warning "batのバージョン情報取得に失敗しました。aptからインストールを試行します..."
                sudo apt-get install -y bat || warning "batのインストールに失敗しました"
            fi
        else
            sudo apt-get install -y bat || warning "batのインストールに失敗しました"
        fi
    fi
    
    # ezaのインストール
    if ! command -v eza &> /dev/null; then
        log "ezaをインストールしています..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update -qq
        sudo apt install -y -qq eza
    fi
    
    # lazygitのインストール
    if ! command -v lazygit &> /dev/null; then
        log "lazygitをインストールしています..."
        # GitHub APIから最新バージョンを取得し、より安定した解析を行う
        if LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' 2>/dev/null) && \
           [ -n "$LAZYGIT_VERSION" ] && [ "$LAZYGIT_VERSION" != "null" ]; then
            # バージョンからvプレフィックスを除去
            VERSION_NUMBER="${LAZYGIT_VERSION#v}"
            
            if [ "$ARCH" = "amd64" ]; then
                LAZYGIT_ARCH="x86_64"
            else
                LAZYGIT_ARCH="arm64"
            fi
            
            DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${VERSION_NUMBER}_Linux_${LAZYGIT_ARCH}.tar.gz"
            log "lazygit ${LAZYGIT_VERSION} をダウンロードしています..."
            
            if curl -fsSL "$DOWNLOAD_URL" | sudo tar xzf - -C /usr/local/bin lazygit; then
                log "lazygitのインストールが完了しました"
            else
                warning "lazygitのダウンロードに失敗しました（URL: $DOWNLOAD_URL）"
            fi
        else
            warning "lazygitのバージョン情報取得に失敗しました"
        fi
    fi
    
    # zoxideのインストール
    if ! command -v zoxide &> /dev/null; then
        log "zoxideをインストールしています..."
        if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
            # PATHに追加（現在のセッション用）
            export PATH="$HOME/.local/bin:$PATH"
            log "zoxideのインストールが完了しました"
        else
            warning "zoxideのインストールに失敗しました"
        fi
    fi
    
    # GitHub CLIのインストール
    if ! command -v gh &> /dev/null; then
        log "GitHub CLIをインストールしています..."
        type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update -qq
        sudo apt install gh -y -qq
    fi
    
    # fnm (Fast Node Manager) のインストール
    if ! command -v fnm &> /dev/null; then
        log "fnmをインストールしています..."
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    fi
}

# =============================================================================
# パッケージのインストール実行
# =============================================================================
install_packages

# =============================================================================
# Node.js環境のセットアップ
# =============================================================================
log "Node.js環境をセットアップしています..."

# fnmの設定を一時的に読み込む
if [ "$OS" = "macos" ]; then
    # macOSの場合
    if [ "$ARCH" = "arm64" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
    else
        export PATH="/usr/local/bin:$PATH"
    fi
    eval "$(fnm env --use-on-cd)"
else
    # Linuxの場合
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
fi

# Node.jsの最新LTS版をインストール
fnm install --lts
fnm use lts-latest
fnm default lts-latest

# pnpmのインストール
if ! command -v pnpm &> /dev/null; then
    log "pnpmをインストールしています..."
    npm install -g pnpm
fi

# =============================================================================
# グローバルパッケージのインストール
# =============================================================================
log "グローバルパッケージをインストールしています..."

# npm グローバルパッケージ
log "npm グローバルパッケージをインストールしています..."
npm install -g \
    @anthropic-ai/claude-code \
    @google/gemini-cli \
    corepack || true

# corepackを有効化
corepack enable || true

# pnpm グローバルパッケージ
log "pnpm グローバルパッケージをインストールしています..."
pnpm install -g \
    @code-dependency/cli \
    difit \
    playwright \
    tsc || true

# playwright用のブラウザをインストール
if command -v playwright &> /dev/null; then
    log "Playwrightブラウザをインストールしています..."
    playwright install chromium || true
fi

# =============================================================================
# 追加のランタイム環境のセットアップ
# =============================================================================
log "追加のランタイム環境をセットアップしています..."

# Bunのセットアップ
if ! command -v bun &> /dev/null; then
    log "Bunをインストールしています..."
    if [ "$OS" = "macos" ]; then
        # macOSの場合はBrewfileでインストール済みのはず
        if ! command -v bun &> /dev/null; then
            curl -fsSL https://bun.sh/install | bash
        fi
    else
        # Linux/Codespacesの場合
        curl -fsSL https://bun.sh/install | bash
    fi
fi

# Bunのパスを追加
export PATH="$HOME/.bun/bin:$PATH"

# Denoのセットアップ（Linux/Codespacesでのみ必要、macOSはBrewでインストール済み）
if [ "$OS" = "linux" ] && ! command -v deno &> /dev/null; then
    log "Denoをインストールしています..."
    curl -fsSL https://deno.land/install.sh | sh
    export PATH="$HOME/.deno/bin:$PATH"
fi

# UVのセットアップ（Python package manager）
if ! command -v uv &> /dev/null; then
    log "UVをインストールしています..."
    if [ "$OS" = "macos" ]; then
        # macOSの場合はBrewfileでインストール済みのはず
        if ! command -v uv &> /dev/null; then
            if curl -LsSf https://astral.sh/uv/install.sh | sh; then
                export PATH="$HOME/.local/bin:$PATH"
                log "UVのインストールが完了しました"
            else
                warning "UVのインストールに失敗しました"
            fi
        fi
    else
        # Linux/Codespacesの場合
        if curl -LsSf https://astral.sh/uv/install.sh | sh; then
            export PATH="$HOME/.local/bin:$PATH"
            log "UVのインストールが完了しました"
        else
            warning "UVのインストールに失敗しました"
        fi
    fi
fi

# =============================================================================
# dotfilesの配置
# =============================================================================
log "dotfilesを配置しています..."

# Codespacesでない場合は、dotfilesを.configにコピー
if ! is_codespaces; then
    # 既存の.configディレクトリをバックアップ
    if [ -d "$HOME/.config" ] && [ "$DOTFILES_SOURCE" != "$HOME/.config" ]; then
        log "既存の.configディレクトリをバックアップしています..."
        if [ -e "$HOME/.config.backup" ]; then
            rm -rf "$HOME/.config.backup"
        fi
        mv "$HOME/.config" "$HOME/.config.backup"
    fi
    
    # dotfilesをコピー（シンボリックリンクではなくコピー）
    if [ "$DOTFILES_SOURCE" != "$HOME/.config" ]; then
        log "dotfilesを.configディレクトリにコピーしています..."
        cp -r "$DOTFILES_SOURCE" "$HOME/.config"
    fi
    
    DOTFILES_TARGET="$HOME/.config"
else
    # Codespacesの場合は元の処理
    log "dotfilesをホームディレクトリにコピーしています..."
    cp -r "$DOTFILES_SOURCE"/* "$DOTFILES_TARGET/" 2>/dev/null || true
    cp -r "$DOTFILES_SOURCE"/.[^.]* "$DOTFILES_TARGET/" 2>/dev/null || true
fi

# =============================================================================
# シンボリックリンクの作成
# =============================================================================
log "設定ファイルのシンボリックリンクを作成しています..."

# zsh設定のシンボリックリンク
if [ -f "$DOTFILES_TARGET/zsh/.zshrc" ]; then
    log "zsh設定をリンクしています..."
    ln -sf "$DOTFILES_TARGET/zsh/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_TARGET/zsh/.zshenv" "$HOME/.zshenv"
fi

# Git設定のシンボリックリンク
if [ -d "$DOTFILES_TARGET/git" ]; then
    log "Git設定をリンクしています..."
    mkdir -p "$HOME/.config/git"
    
    # config.templateがある場合は、それをベースに設定
    if [ -f "$DOTFILES_TARGET/git/config.template" ] && [ ! -f "$HOME/.config/git/config" ]; then
        log "Git設定テンプレートから設定を作成しています..."
        cp "$DOTFILES_TARGET/git/config.template" "$HOME/.config/git/config"
        warning "Git設定ファイルをテンプレートから作成しました。"
        warning "以下のコマンドで個人情報を設定してください："
        warning "  git config --global user.name \"Your Name\""
        warning "  git config --global user.email \"your@email.com\""
        warning "  git config --global user.signingkey \"YOUR_GPG_KEY_ID\""
    elif [ -f "$DOTFILES_TARGET/git/config" ]; then
        # 既存のconfigファイルがある場合（後方互換性）
        ln -sf "$DOTFILES_TARGET/git/config" "$HOME/.config/git/config"
    fi
    
    # gitignoreはそのままリンク
    if [ -f "$DOTFILES_TARGET/git/ignore" ]; then
        ln -sf "$DOTFILES_TARGET/git/ignore" "$HOME/.config/git/ignore"
    fi
fi

# Neovim設定のシンボリックリンク
if [ -d "$DOTFILES_TARGET/nvim" ]; then
    log "Neovim設定をリンクしています..."
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_TARGET/nvim" "$HOME/.config/nvim"
fi

# Claude設定のシンボリックリンク
if [ -d "$DOTFILES_TARGET/.claude" ]; then
    log "Claude設定をリンクしています..."
    ln -sf "$DOTFILES_TARGET/.claude" "$HOME/.claude"
fi

# tmux設定（存在する場合）
if [ -f "$DOTFILES_TARGET/tmux/tmux.conf" ]; then
    log "tmux設定をリンクしています..."
    ln -sf "$DOTFILES_TARGET/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

# SSH設定テンプレート（存在する場合）
if [ -f "$DOTFILES_TARGET/ssh/config.template" ]; then
    log "SSH設定テンプレートを配置しています..."
    mkdir -p "$HOME/.ssh"
    if [ ! -f "$HOME/.ssh/config" ]; then
        cp "$DOTFILES_TARGET/ssh/config.template" "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
        warning "SSH設定をテンプレートから作成しました。必要に応じて編集してください。"
    else
        info "SSH設定が既に存在します。テンプレートは ~/.ssh/config.template として配置されました。"
        cp "$DOTFILES_TARGET/ssh/config.template" "$HOME/.ssh/config.template"
    fi
fi

# GPG設定（存在する場合）
if [ -f "$DOTFILES_TARGET/gnupg/gpg-agent.conf" ]; then
    # Codespacesや軽量環境ではGPGサービスをスキップ
    if is_codespaces || is_vscode_server; then
        info "Codespaces/VS Code Server環境のため、GPG設定をスキップしています..."
    else
        log "GPG設定を配置しています..."
        mkdir -p "$HOME/.gnupg"
        chmod 700 "$HOME/.gnupg"
        if [ ! -f "$HOME/.gnupg/gpg-agent.conf" ]; then
            cp "$DOTFILES_TARGET/gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
            chmod 600 "$HOME/.gnupg/gpg-agent.conf"
            log "GPG Agent設定を配置しました。"
        fi
    fi
fi

# =============================================================================
# OS固有の設定
# =============================================================================
if [ "$OS" = "macos" ]; then
    log "macOS固有の設定を適用しています..."
    
    # Karabiner設定
    if [ -d "$DOTFILES_TARGET/karabiner" ] && [ -d "$HOME/.config" ]; then
        log "Karabiner設定をリンクしています..."
        mkdir -p "$HOME/.config"
        ln -sf "$DOTFILES_TARGET/karabiner" "$HOME/.config/karabiner"
    fi
    
    # Ghostty設定
    if [ -d "$DOTFILES_TARGET/ghostty" ]; then
        log "Ghostty設定をリンクしています..."
        mkdir -p "$HOME/.config"
        ln -sf "$DOTFILES_TARGET/ghostty" "$HOME/.config/ghostty"
    fi
    
    # iTerm2設定（plistファイルがある場合）
    if [ -f "$DOTFILES_TARGET/iterm2/com.googlecode.iterm2.plist" ]; then
        log "iTerm2設定を配置しています..."
        cp "$DOTFILES_TARGET/iterm2/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/"
    fi
fi

# =============================================================================
# シェルの変更
# =============================================================================
log "デフォルトシェルをzshに変更しています..."
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    if [ "$OS" = "macos" ]; then
        # macOSの場合
        sudo dscl . -create /Users/$USER UserShell $ZSH_PATH
    else
        # Linuxの場合
        sudo chsh -s $ZSH_PATH "$USER"
    fi
fi

# =============================================================================
# 追加の設定
# =============================================================================
log "追加の設定を行っています..."

# Neovimプラグインのインストール
if command -v nvim &> /dev/null && [ -d "$HOME/.config/nvim" ]; then
    # Codespacesでは軽量化のためプラグインインストールをスキップするオプション
    if is_codespaces && [ "${SKIP_NVIM_PLUGINS:-false}" = "true" ]; then
        info "SKIP_NVIM_PLUGINS=trueのため、Neovimプラグインのインストールをスキップしています..."
    else
        log "Neovimプラグインをインストールしています..."
        timeout 300 nvim --headless "+Lazy! sync" +qa || {
            warning "Neovimプラグインのインストールがタイムアウトまたは失敗しました"
        }
    fi
fi

# =============================================================================
# 完了メッセージ
# =============================================================================
log "✨ dotfilesのセットアップが完了しました！"
log ""
log "次のステップ："
log "1. 新しいターミナルを開くか、以下のコマンドを実行してzshを起動してください："
log "   exec zsh"
log ""

if [ "$OS" = "macos" ]; then
    log "2. macOS固有の設定："
    log "   - Karabiner-Elementsを起動して設定を有効化"
    log "   - iTerm2の設定を反映するには再起動が必要"
elif is_codespaces; then
    log "2. Codespaces固有の設定："
    log "   - Git個人設定が必要です："
    log "     git config --global user.name \"Your Name\""
    log "     git config --global user.email \"your@email.com\""
    log "   - GitHub CLI認証が必要です："
    log "     gh auth login"
    if [ "${SKIP_NVIM_PLUGINS:-false}" = "true" ]; then
        log "   - Neovimプラグインは手動でインストールしてください："
        log "     nvim +\"Lazy! sync\" +qa"
    fi
fi

# エラーまたは警告があった場合の案内
if [ -f "/tmp/dotfiles_warnings.log" ]; then
    warning "セットアップ中に警告がありました。詳細は /tmp/dotfiles_warnings.log を確認してください。"
fi

# デバッグ情報の出力
if [ "${DEBUG:-false}" = "true" ]; then
    log ""
    log "デバッグ情報:"
    log "  OS: $OS"
    log "  ARCH: $ARCH"
    log "  CODESPACES: $(is_codespaces && echo 'true' || echo 'false')"
    log "  DOTFILES_SOURCE: $DOTFILES_SOURCE"
    log "  DOTFILES_TARGET: $DOTFILES_TARGET"
    log "  HOME: $HOME"
    log "  USER: $USER"
    log "  SHELL: $SHELL"
fi