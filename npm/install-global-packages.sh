#!/bin/bash

# npm グローバルパッケージを復元するスクリプト
echo "npm グローバルパッケージをインストールしています..."

# 設定ファイルの場所
CONFIG_FILE="$HOME/.config/npm/global-packages.json"

# 設定ファイルが存在するかチェック
if [ ! -f "$CONFIG_FILE" ]; then
    echo "エラー: $CONFIG_FILE が見つかりません"
    exit 1
fi

# jq がインストールされているかチェック
if ! command -v jq &> /dev/null; then
    echo "jq がインストールされていません。インストールしてください。"
    echo "macOS: brew install jq"
    echo "Ubuntu/Debian: sudo apt-get install jq"
    exit 1
fi

# パッケージをインストール
while IFS= read -r line; do
    package=$(echo "$line" | cut -d'"' -f2)
    version=$(echo "$line" | cut -d'"' -f4)
    
    if [ -n "$package" ] && [ "$package" != "{" ] && [ "$package" != "}" ]; then
        if [ "$version" = "latest" ]; then
            echo "インストール中: $package@latest"
            npm install -g "$package@latest"
        else
            echo "インストール中: $package@$version"
            npm install -g "$package@$version"
        fi
    fi
done < <(cat "$CONFIG_FILE")

echo "完了！インストールされたパッケージ:"
npm list -g --depth=0