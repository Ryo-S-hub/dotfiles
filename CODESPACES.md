# GitHub Codespaces セットアップガイド

このドキュメントでは、GitHub Codespacesでdotfilesを使用する際の特別な設定について説明します。

## 自動セットアップ

### 1. Codespaces設定の有効化

1. GitHub → Settings → Codespaces
2. 「Automatically install dotfiles」をONにする
3. Repository: `YOUR_USERNAME/dotfiles` を設定

### 2. 環境変数の設定

Codespacesでのパフォーマンス最適化のため、以下の環境変数を設定できます：

- `SKIP_NVIM_PLUGINS=true` - Neovimプラグインのインストールをスキップ
- `DEBUG=true` - デバッグ情報を表示

設定方法：
1. GitHub → Settings → Codespaces
2. 「Codespaces secrets」セクション
3. 環境変数を追加

## Codespaces固有の機能

### 軽量化された設定

Codespacesでは以下の最適化が自動的に適用されます：

1. **パッケージの軽量化**
   - 基本的なツールのみインストール
   - ビルドツールなどはスキップ

2. **サービスの無効化**
   - GPG Agentなどの重いサービスをスキップ
   - リソース使用量を最小化

3. **プラグインの制御**
   - Neovimプラグインの自動インストールを制御可能
   - タイムアウト設定でハングアップを防止

## 手動設定が必要な項目

### Git設定

```bash
# 個人情報の設定
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# GPG署名（オプション）
git config --global user.signingkey "YOUR_GPG_KEY_ID"
git config --global commit.gpgsign true
```

### GitHub CLI認証

```bash
# GitHub CLI認証
gh auth login
```

### SSH設定（オプション）

Codespacesは主にHTTPS認証を使用しますが、SSH鍵も設定可能です：

```bash
# SSH鍵を生成
ssh-keygen -t ed25519 -C "your_email@example.com"

# 公開鍵をGitHubに追加
cat ~/.ssh/id_ed25519.pub
```

## トラブルシューティング

### よくある問題

1. **Neovimプラグインのインストールが遅い**
   ```bash
   export SKIP_NVIM_PLUGINS=true
   ./install.sh
   ```

2. **パッケージインストールエラー**
   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   ```

3. **権限エラー**
   ```bash
   # Codespacesでは通常sudoパスワードは不要
   # エラーが出る場合は環境変数を確認
   echo $SUDO_ASKPASS
   ```

### デバッグ方法

```bash
# デバッグモードで実行
DEBUG=true ./install.sh

# 環境情報の確認
echo "CODESPACES: $CODESPACES"
echo "USER: $USER"
echo "HOME: $HOME"
whoami
```

## パフォーマンス最適化

### リソース使用量の確認

```bash
# CPU使用量
top -bn1 | grep "Cpu(s)"

# メモリ使用量
free -h

# ディスク使用量
df -h
```

### 軽量化のコツ

1. **必要最小限のツールのみインストール**
2. **プラグインの自動インストールをスキップ**
3. **バックグラウンドサービスを最小化**

## カスタマイズ

### Codespaces専用設定

`.github/codespaces/devcontainer.json` でCodespaces固有の設定を行えます：

```json
{
  "containerEnv": {
    "SKIP_NVIM_PLUGINS": "true",
    "CUSTOM_SETTING": "value"
  },
  "postCreateCommand": "echo 'Custom setup command'"
}
```

### VS Code拡張機能

Codespacesで自動インストールする拡張機能を設定：

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-json",
        "GitHub.copilot"
      ]
    }
  }
}
```

## 更新とメンテナンス

### dotfilesの更新

```bash
# Codespacesでdotfilesを更新
cd ~/.config
git pull origin main
./install.sh
```

### 環境のリセット

問題が発生した場合：

1. Codespacesを削除して新しく作成
2. または手動でリセット：

```bash
# 設定ファイルをリセット
rm -rf ~/.config
rm -rf ~/.zshrc ~/.zshenv

# 再インストール
./install.sh
```