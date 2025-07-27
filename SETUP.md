# Dotfiles セットアップガイド

このガイドでは、新しい環境でdotfilesを完全にセットアップする手順を説明します。

## 自動セットアップ

### GitHub Codespaces

1. Codespacesで新しい環境を作成すると、自動的に`install.sh`が実行されます
2. 設定完了後、新しいターミナルを開いてzshを起動してください

### ローカル環境（macOS/Linux）

```bash
# リポジトリをクローン
git clone https://github.com/[your-username]/dotfiles.git ~/.config

# セットアップスクリプトを実行
cd ~/.config
./install.sh

# 新しいシェルセッションを開始
exec zsh
```

## 手動セットアップが必要な項目

自動セットアップでは設定できない、セキュリティ上重要な項目について説明します。

### 1. SSH鍵の設定

#### 新しい鍵を生成する場合：

```bash
# SSH鍵を生成
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# SSH Agentに追加
ssh-add ~/.ssh/id_rsa

# 公開鍵をクリップボードにコピー（macOS）
pbcopy < ~/.ssh/id_rsa.pub

# 公開鍵をクリップボードにコピー（Linux）
cat ~/.ssh/id_rsa.pub | xclip -sel clip
```

#### 既存の鍵を移行する場合：

```bash
# 既存環境から鍵をコピー
scp user@old-machine:~/.ssh/id_rsa ~/.ssh/
scp user@old-machine:~/.ssh/id_rsa.pub ~/.ssh/

# 権限を設定
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# SSH Agentに追加
ssh-add ~/.ssh/id_rsa
```

#### GitHub/GitLabに公開鍵を追加：

1. GitHub: Settings → SSH and GPG keys → New SSH key
2. GitLab: Preferences → SSH Keys → Add key

### 2. GPG鍵の設定

#### 新しい鍵を生成する場合：

```bash
# GPG鍵を生成
gpg --full-generate-key

# 鍵IDを確認
gpg --list-secret-keys --keyid-format LONG

# 公開鍵をエクスポート（GitHubに追加用）
gpg --armor --export [YOUR_KEY_ID]

# Gitに設定
git config --global user.signingkey [YOUR_KEY_ID]
git config --global commit.gpgsign true
```

#### 既存の鍵を移行する場合：

```bash
# 既存環境で鍵をエクスポート
gpg --export-secret-keys [KEY_ID] > private.key
gpg --export [KEY_ID] > public.key

# 新環境でインポート
gpg --import public.key
gpg --import private.key

# 信頼レベル設定
gpg --edit-key [KEY_ID]
# trust コマンドで信頼レベルを「5」（ultimate）に設定
```

### 3. 認証情報の設定

#### Git設定：

```bash
# ユーザー情報を設定（まだ設定していない場合）
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

#### クラウドサービス認証：

```bash
# GitHub CLI認証
gh auth login

# AWS CLI認証（必要に応じて）
aws configure sso

# その他のクラウドサービス
# Azure: az login
# Google Cloud: gcloud auth login
```

### 4. アプリケーション固有の設定

#### macOS専用：

1. **Karabiner-Elements**:
   - アプリを起動して設定を有効化
   - 必要に応じてセキュリティ設定で入力監視を許可

2. **iTerm2**:
   - 設定が自動適用されない場合は再起動
   - カラースキームやフォント設定を確認

3. **Spotlight除外設定**:
   ```bash
   # node_modulesなどをSpotlightから除外
   sudo mdutil -i off ~/workspace/*/node_modules
   ```

#### Linux/Codespaces専用：

1. **フォント設定**:
   ```bash
   # Nerd Fontsをインストール（必要に応じて）
   mkdir -p ~/.local/share/fonts
   cd ~/.local/share/fonts
   curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" \
     https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
   fc-cache -fv
   ```

### 5. 開発環境のカスタマイズ

#### VS Code拡張機能：

settings.jsonで推奨拡張機能を確認し、必要に応じてインストール：

```bash
# VS Code拡張機能のリストを確認
code --list-extensions
```

#### ブラウザ設定：

1. 開発者ツールの設定
2. 拡張機能の設定（React DevTools、Vue DevTools等）

## トラブルシューティング

### よくある問題と解決方法

1. **zshが起動しない**:
   ```bash
   # デフォルトシェルの確認と変更
   echo $SHELL
   chsh -s $(which zsh)
   ```

2. **fnm/Node.jsが認識されない**:
   ```bash
   # PATHの再読み込み
   source ~/.zshrc
   ```

3. **GPG署名でエラーが出る**:
   ```bash
   # GPG Agentの再起動
   gpg-connect-agent reloadagent /bye
   ```

4. **Homebrew関連のエラー**:
   ```bash
   # Homebrewの診断と修復
   brew doctor
   brew update
   ```

## セキュリティ注意事項

⚠️ **重要**: このdotfilesリポジトリは公開前にセキュリティ対策が施されています。

### 除外されている機密情報

以下の情報は自動的に除外されており、手動でセットアップする必要があります：

1. **Git個人設定**: `git/config`は除外されており、`git/config.template`を使用
2. **SSH鍵**: すべてのSSH秘密鍵は除外
3. **GPG鍵**: GPG秘密鍵関連ファイルは除外
4. **認証トークン**: API トークン、パスワード、認証情報は除外
5. **クラウドサービス設定**: AWS、GCP、Azure の認証情報は除外

### 公開前のチェックリスト

dotfilesを公開する前に以下を確認してください：

```bash
# 機密情報が含まれていないかチェック
git log --patch | grep -i -E "(password|token|key|secret|credential)"

# 個人情報が含まれていないかチェック
grep -r -i "YOUR_ACTUAL_NAME\|YOUR_ACTUAL_EMAIL" .

# .gitignoreが正しく機能しているか確認
git status --ignored
```

## 環境確認コマンド

セットアップが正常に完了したかを確認するためのコマンド：

```bash
# 基本ツールの確認
command -v zsh && echo "✓ zsh"
command -v nvim && echo "✓ neovim"
command -v git && echo "✓ git"
command -v gh && echo "✓ github-cli"

# 開発環境の確認
command -v node && echo "✓ node $(node --version)"
command -v pnpm && echo "✓ pnpm $(pnpm --version)"
command -v bun && echo "✓ bun $(bun --version)"
command -v deno && echo "✓ deno $(deno --version)"

# Git設定の確認（個人情報がテンプレートのままでないか確認）
git config --global --list | grep user
git config --global user.name | grep -v "YOUR_NAME_HERE" || echo "⚠️ Git名前設定が必要"
git config --global user.email | grep -v "YOUR_EMAIL_HERE" || echo "⚠️ Gitメール設定が必要"

# SSH接続テスト
ssh -T git@github.com

# GPG設定の確認
gpg --list-secret-keys
```

## 更新とメンテナンス

### dotfilesの更新：

```bash
cd ~/.config
git pull origin main
./install.sh  # 必要に応じて再実行
```

### Brewfileの更新（macOS）：

```bash
cd ~/.config
brew bundle dump --force  # 現在の環境をBrewfileに反映
git add Brewfile
git commit -m "Update Brewfile"
```

### パッケージの定期更新：

```bash
# Homebrew（macOS）
brew update && brew upgrade

# Node.js（fnm使用の場合）
fnm install --lts
fnm use lts-latest
fnm default lts-latest

# Python（uv使用の場合）
uv self update
```