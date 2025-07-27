# GitHub Codespaces dotfiles セットアップガイド

## 概要

GitHub Codespacesでdotfilesが自動実行されない問題の解決方法を説明します。

## 事前設定

### 1. GitHub Settings でのdotfiles設定

1. https://github.com/settings/codespaces にアクセス
2. **「Automatically install dotfiles」** を有効化
3. **「Repository」** で dotfiles リポジトリを選択
4. **「Included files」** は通常空欄でOK（全ファイルが対象）

### 2. dotfilesリポジトリの要件

以下のいずれかのセットアップスクリプトをリポジトリのルートに配置：

- `install.sh`
- `bootstrap.sh`  
- `setup.sh`

スクリプトには実行権限が必要：

```bash
chmod +x install.sh
```

### 3. プライベートリポジトリの場合

Codespacesからのアクセス権限を設定：

1. dotfilesリポジトリの Settings → Manage access
2. Codespaces用のアクセス権限を追加

## トラブルシューティング

### 問題1: dotfilesが実行されない

**症状**: Codespaces作成後にdotfilesのセットアップが実行されない

**解決策**:

1. **設定確認**: GitHub Settings → Codespaces でdotfiles設定を確認
2. **新しいCodespace作成**: 設定変更後は新しいCodespaceが必要
3. **手動実行**: デバッグスクリプトで問題を特定

```bash
# デバッグスクリプトの実行
./debug-codespaces.sh

# dotfilesディレクトリが見つかった場合の手動実行
cd ~/.dotfiles && ./install.sh
```

### 問題2: パスが見つからない

**症状**: "dotfilesディレクトリが見つかりません" エラー

**原因と対策**:

- **Codespaces固有のパス問題**: 修正済みのinstall.shを使用
- **権限問題**: リポジトリアクセス権限を確認
- **タイミング問題**: Codespaces作成完了後にdotfiles処理が実行される

### 問題3: スクリプトが実行されない

**症状**: dotfilesディレクトリは存在するが、セットアップが実行されない

**対策**:

1. **実行権限確認**:
   ```bash
   ls -la install.sh
   chmod +x install.sh
   ```

2. **ファイル名確認**: `install.sh`、`bootstrap.sh`、`setup.sh` のいずれか

3. **シェバン確認**: スクリプトの1行目が `#!/bin/bash` または `#!/bin/sh`

## 修正済みの改善点

### 1. 複数パス候補の自動検索

修正されたinstall.shは以下のパスを順次検索します：

- `$HOME/.dotfiles`
- `/workspaces/.codespaces/.persistedshare/dotfiles`
- `/tmp/.dotfiles`
- `$(pwd)` (現在のディレクトリ)

### 2. 詳細なデバッグ情報

実行時に以下の情報を出力：

- Codespaces環境変数の詳細
- 検索した全パス候補
- ディレクトリ構造の状況
- 具体的なエラー対策

### 3. トラブルシューティング支援

エラー時に表示される情報：

- 設定確認手順
- 一般的な問題の解決策
- 現在の環境状況

## 使用方法

### 1. 通常の使用（自動実行）

Codespaces作成時に自動的に実行されます。

### 2. 手動実行

```bash
# dotfilesディレクトリで実行
./install.sh

# デバッグ情報付きで実行
bash -x ./install.sh
```

### 3. 問題診断

```bash
# 診断スクリプトの実行
./debug-codespaces.sh
```

## 注意事項

1. **既存のCodespaces**: 設定変更は新しいCodespaceでのみ有効
2. **プライベートリポジトリ**: アクセス権限の設定が必要
3. **セキュリティ**: dotfilesは任意のスクリプトを実行できるため、信頼できるリポジトリのみ使用
4. **実行順序**: Codespaces作成 → dotfilesクローン → セットアップスクリプト実行

## 参考リンク

- [GitHub Codespaces Personalization](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account)
- [Codespaces Settings](https://github.com/settings/codespaces)