#!/bin/bash
# GitHub Codespaces用のdotfilesセットアップスクリプト
# このスクリプトはCodespacesが新しい環境を作成する際に自動的に実行されます

set -euo pipefail

# カラー出力のための定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# メイン処理の開始
log "GitHub Codespaces dotfiles セットアップを開始します..."

# ユーザー情報の取得
if [ -z "${USER:-}" ]; then
    USER=$(id -un)
fi

log "ユーザー: $USER"
log "ホームディレクトリ: $HOME"

# Codespacesがクローンしたdotfilesの場所
DOTFILES_SOURCE="/workspaces/.codespaces/.persistedshare/dotfiles"
DOTFILES_TARGET="$HOME/.config"

# dotfilesが正しい場所にあるか確認
if [ ! -d "$DOTFILES_SOURCE" ]; then
    error "dotfilesディレクトリが見つかりません: $DOTFILES_SOURCE"
    exit 1
fi

# .configディレクトリの作成
mkdir -p "$HOME/.config"

# 一時的にsudoパスワードなしで実行できるようにする
export SUDO_ASKPASS=/bin/true

# =============================================================================
# システムパッケージのアップデートとインストール
# =============================================================================
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

# =============================================================================
# 開発ツールのインストール
# =============================================================================
log "開発ツールをインストールしています..."

# Neovimのインストール（最新の安定版）
if ! command -v nvim &> /dev/null; then
    log "Neovimをインストールしています..."
    curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz | \
        sudo tar -C /opt -xzf -
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
fi

# ripgrepのインストール
if ! command -v rg &> /dev/null; then
    log "ripgrepをインストールしています..."
    curl -fsSL https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep_14.1.0_amd64.deb -o /tmp/ripgrep.deb
    sudo dpkg -i /tmp/ripgrep.deb
    rm /tmp/ripgrep.deb
fi

# fd-findのインストール
if ! command -v fd &> /dev/null; then
    log "fd-findをインストールしています..."
    curl -fsSL https://github.com/sharkdp/fd/releases/latest/download/fd_10.1.0_amd64.deb -o /tmp/fd.deb
    sudo dpkg -i /tmp/fd.deb
    rm /tmp/fd.deb
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
    curl -fsSL https://github.com/sharkdp/bat/releases/latest/download/bat_0.24.0_amd64.deb -o /tmp/bat.deb
    sudo dpkg -i /tmp/bat.deb
    rm /tmp/bat.deb
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
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" | \
        sudo tar xzf - -C /usr/local/bin lazygit
fi

# zoxideのインストール
if ! command -v zoxide &> /dev/null; then
    log "zoxideをインストールしています..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# GitHub CLIのインストール（既にインストールされていない場合）
if ! command -v gh &> /dev/null; then
    log "GitHub CLIをインストールしています..."
    type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update -qq
    sudo apt install gh -y -qq
fi

# =============================================================================
# Node.js環境のセットアップ
# =============================================================================
log "Node.js環境をセットアップしています..."

# fnm (Fast Node Manager) のインストール
if ! command -v fnm &> /dev/null; then
    log "fnmをインストールしています..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# fnmの設定を一時的に読み込む
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

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
# dotfilesのシンボリックリンク作成
# =============================================================================
log "dotfilesのシンボリックリンクを作成しています..."

# 既存の.configディレクトリをバックアップ（必要な場合）
if [ -d "$HOME/.config" ] && [ ! -L "$HOME/.config" ]; then
    log "既存の.configディレクトリをバックアップしています..."
    mv "$HOME/.config" "$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
fi

# dotfilesを適切な場所にコピー
log "dotfilesをホームディレクトリにコピーしています..."
cp -r "$DOTFILES_SOURCE"/* "$DOTFILES_TARGET/" 2>/dev/null || true
cp -r "$DOTFILES_SOURCE"/.[^.]* "$DOTFILES_TARGET/" 2>/dev/null || true

# zsh設定のシンボリックリンク
log "zsh設定をリンクしています..."
ln -sf "$DOTFILES_TARGET/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_TARGET/zsh/.zshenv" "$HOME/.zshenv"

# Git設定のシンボリックリンク
log "Git設定をリンクしています..."
mkdir -p "$HOME/.config/git"
ln -sf "$DOTFILES_TARGET/git/config" "$HOME/.config/git/config"
ln -sf "$DOTFILES_TARGET/git/ignore" "$HOME/.config/git/ignore"

# Neovim設定のシンボリックリンク
log "Neovim設定をリンクしています..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_TARGET/nvim" "$HOME/.config/nvim"

# Claude設定のシンボリックリンク
log "Claude設定をリンクしています..."
ln -sf "$DOTFILES_TARGET/.claude" "$HOME/.claude"

# tmux設定（存在する場合）
if [ -f "$DOTFILES_TARGET/tmux/tmux.conf" ]; then
    log "tmux設定をリンクしています..."
    ln -sf "$DOTFILES_TARGET/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

# =============================================================================
# シェルの変更
# =============================================================================
log "デフォルトシェルをzshに変更しています..."
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    sudo chsh -s /usr/bin/zsh "$USER"
fi

# =============================================================================
# 追加の設定
# =============================================================================
log "追加の設定を行っています..."

# Neovimプラグインのインストール
if command -v nvim &> /dev/null; then
    log "Neovimプラグインをインストールしています..."
    nvim --headless "+Lazy! sync" +qa || true
fi

# =============================================================================
# 完了メッセージ
# =============================================================================
log "✨ dotfilesのセットアップが完了しました！"
log "新しいターミナルを開くか、以下のコマンドを実行してzshを起動してください："
log "  exec zsh"

# デバッグ情報の出力
if [ "${DEBUG:-false}" = "true" ]; then
    log "デバッグ情報:"
    log "  DOTFILES_SOURCE: $DOTFILES_SOURCE"
    log "  DOTFILES_TARGET: $DOTFILES_TARGET"
    log "  HOME: $HOME"
    log "  USER: $USER"
    log "  SHELL: $SHELL"
fi