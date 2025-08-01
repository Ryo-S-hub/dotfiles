# npm グローバルパッケージ管理

このディレクトリは npm でグローバルにインストールされたパッケージを管理します。

## ファイル構成

- `global-packages.json` - グローバルパッケージのリスト（常に最新版を使用）
- `install-global-packages.sh` - パッケージを復元するスクリプト

## 使い方

### 新しいPCでパッケージを復元する

1. このディレクトリ（`.config/npm`）を新しいPCにコピー
2. 以下のコマンドを実行:

```bash
cd ~/.config/npm
./install-global-packages.sh
```

### パッケージリストを更新する

新しいパッケージをグローバルインストールした場合、`global-packages.json` に手動で追加してください：

```json
{
  "パッケージ名": "latest"
}
```

## 注意事項

- すべてのパッケージは `latest` バージョンでインストールされます
- スクリプトを実行する前に `jq` をインストールしてください
  - macOS: `brew install jq`
  - Ubuntu/Debian: `sudo apt-get install jq`