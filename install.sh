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

OS=$(detect_os)
ARCH=$(detect_arch)

# メイン処理の開始
log "Universal dotfiles セットアップを開始します..."
log "OS: $OS"
log "Architecture: $ARCH"
if is_codespaces; then
    log "Environment: GitHub Codespaces"
else
    log "Environment: Local"
fi

# ユーザー情報の取得
if [ -z "${USER:-}" ]; then
    USER=$(id -un)
fi

log "ユーザー: $USER"
log "ホームディレクトリ: $HOME"

# dotfilesのパス設定
if is_codespaces; then
    # Codespacesの場合
    DOTFILES_SOURCE="/workspaces/.codespaces/.persistedshare/dotfiles"
else
    # ローカル環境の場合（スクリプトが実行されているディレクトリ）
    DOTFILES_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

DOTFILES_TARGET="$HOME/.config"

# dotfilesが正しい場所にあるか確認
if [ ! -d "$DOTFILES_SOURCE" ]; then
    error "dotfilesディレクトリが見つかりません: $DOTFILES_SOURCE"
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
    
    # 一時的にsudoパスワードなしで実行できるようにする（Codespaces用）
    if is_codespaces; then
        export SUDO_ASKPASS=/bin/true
    fi
    
    # システムパッケージの更新
    log "システムパッケージを更新しています..."
    sudo apt-get update -qq
    
    log "基本的なパッケージをインストールしています..."
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
        python3-venv
    
    # Neovimのインストール
    if ! command -v nvim &> /dev/null; then
        log "Neovimをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz | \
                sudo tar -C /opt -xzf -
            sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
        else
            # ARM64の場合はaptから
            sudo apt-get install -y neovim
        fi
    fi
    
    # ripgrepのインストール
    if ! command -v rg &> /dev/null; then
        log "ripgrepをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            RIPGREP_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep -Po '"tag_name": "\K[^"]*')
            curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep_${RIPGREP_VERSION#v}_amd64.deb" -o /tmp/ripgrep.deb
            sudo dpkg -i /tmp/ripgrep.deb
            rm /tmp/ripgrep.deb
        else
            sudo apt-get install -y ripgrep
        fi
    fi
    
    # fd-findのインストール
    if ! command -v fd &> /dev/null; then
        log "fd-findをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
            curl -fsSL "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb" -o /tmp/fd.deb
            sudo dpkg -i /tmp/fd.deb
            rm /tmp/fd.deb
        else
            sudo apt-get install -y fd-find
            sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
        fi
    fi
    
    # fzfのインストール
    if ! command -v fzf &> /dev/null; then
        log "fzfをインストールしています..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all --no-bash --no-fish
    fi
    
    # batのインストール
    if ! command -v bat &> /dev/null; then
        log "batをインストールしています..."
        if [ "$ARCH" = "amd64" ]; then
            BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
            curl -fsSL "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb" -o /tmp/bat.deb
            sudo dpkg -i /tmp/bat.deb
            rm /tmp/bat.deb
        else
            sudo apt-get install -y bat
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
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        if [ "$ARCH" = "amd64" ]; then
            LAZYGIT_ARCH="x86_64"
        else
            LAZYGIT_ARCH="arm64"
        fi
        curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" | \
            sudo tar xzf - -C /usr/local/bin lazygit
    fi
    
    # zoxideのインストール
    if ! command -v zoxide &> /dev/null; then
        log "zoxideをインストールしています..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
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
            curl -LsSf https://astral.sh/uv/install.sh | sh
        fi
    else
        # Linux/Codespacesの場合
        curl -LsSf https://astral.sh/uv/install.sh | sh
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
    ln -sf "$DOTFILES_TARGET/git/config" "$HOME/.config/git/config"
    ln -sf "$DOTFILES_TARGET/git/ignore" "$HOME/.config/git/ignore"
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
    log "GPG設定を配置しています..."
    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"
    if [ ! -f "$HOME/.gnupg/gpg-agent.conf" ]; then
        cp "$DOTFILES_TARGET/gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
        chmod 600 "$HOME/.gnupg/gpg-agent.conf"
        log "GPG Agent設定を配置しました。"
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
    log "Neovimプラグインをインストールしています..."
    nvim --headless "+Lazy! sync" +qa || true
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