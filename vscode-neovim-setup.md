# VSCode Neovim設定 (2025年最新版)

VSCodeVim拡張機能の設定をVSCode Neovim拡張機能で再現するための設定です。

## 最新機能ハイライト

- ✅ **最新VSCode Neovim API活用**: `vscode.action()`, `vscode.with_insert()`, `vscode.eval()`
- ✅ **Composite Keyサポート**: jj, jk, kj, ;;, ,, などの2文字キー
- ✅ **VSCode設定連携**: 設定の取得・更新機能
- ✅ **パフォーマンス最適化**: 遅延読み込みから即座読み込みへ
- ✅ **日本語対応**: 自動入力切り替え、日本語括弧サポート

## セットアップ手順

### 1. 拡張機能のインストール

VSCodeで以下の拡張機能をインストール：
- **VSCode Neovim** (`asvetliakov.vscode-neovim`)

### 2. VSCode設定の更新

VSCodeの`settings.json`に以下の設定を追加または更新：

```json
{
  "// VSCode Neovim 拡張機能の基本設定": "",
  "vim.neovimConfigPath": "~/.config/nvim/init.lua",
  "vim.neovimUseConfigFile": true,
  "vim.leader": "<space>",
  
  "// Composite Key設定 - 2文字キーの組み合わせ": "",
  "vscode-neovim.compositeKeys": {
    "jj": { "command": "vscode-neovim.escape" },
    "jk": {
      "command": "vscode-neovim.lua",
      "args": [
        [
          "local vscode = require('vscode')",
          "vscode.action('vscode-neovim.escape')",
          "vscode.action('workbench.action.files.save')"
        ]
      ]
    },
    "kj": {
      "command": "vscode-neovim.lua",
      "args": [
        [
          "local vscode = require('vscode')",
          "vscode.action('vscode-neovim.escape')",
          "vscode.action('editor.action.formatDocument')"
        ]
      ]
    },
    ";;": {
      "command": "vscode-neovim.lua",
      "args": [[ "vscode.action('workbench.action.quickOpen')" ]]
    },
    ",,": {
      "command": "vscode-neovim.lua",
      "args": [[ "vscode.action('workbench.action.showCommands')" ]]
    }
  }
}
```

### 3. 既存のVSCodeVim設定の削除

以下のVSCodeVim設定は不要になるため削除可能：
- `vim.insertModeKeyBindings`
- `vim.normalModeKeyBindings`
- `vim.normalModeKeyBindingsNonRecursive`
- `vim.visualModeKeyBindings`
- `vim.visualModeKeyBindingsNonRecursive`
- `vim.camelCaseMotion.enable`
- `vim.easymotion`
- `vim.surround`
- `vim.targets.enable`
- `vim.sneak`
- `vim.replaceWithRegister`
- `vim.visualstar`
- `vim.foldfix`
- `vim.autoSwitchInputMethod.*`

### 4. プラグインの自動インストール

Neovimを起動すると、lazy.nvimが必要なプラグインを自動的にインストールします。

## 機能一覧

### 新機能 (2025年更新)

**Composite Key:**
- `jj` → エスケープ
- `jk` → エスケープ + 保存
- `kj` → エスケープ + フォーマット
- `;;` → ファイル検索 (Ctrl+P)
- `,,` → コマンドパレット (Ctrl+Shift+P)

**VSCode設定連携:**
- `<leader>vt` → タブサイズ表示
- `<leader>vc` → フォントファミリー、タブサイズ表示
- `<leader>vf` → 現在のファイルパス表示
- `<leader>vy` → カーソル下の単語をクリップボードにコピー

**高度なVSCode連携:**
- `=` / `==` → フォーマット機能
- `<C-w>gd` → 定義を新しいパネルで開く
- `?` → カーソル下の単語でファイル検索
- `<leader>r` → リファクタリング
- `<C-d>` → 次の一致を選択

## 移植済み機能

### キーバインディング

**インサートモード:**
- `jj`, `kk` → Escapeキー
- `Ctrl+j` → 前方検索（*）してインサートモードに戻る
- `Ctrl+k` → 後方検索（#）してインサートモードに戻る
- `Ctrl+i` → surround機能（ysiw）
- `Ctrl+v` → ビジュアルモードに移行

**ノーマルモード:**
- `Ctrl+j` → 前方検索（*）
- `Ctrl+k` → 後方検索（#）
- `Ctrl+i` → surround機能（ysiw）
- 日本語キー対応：
  - `あ` → `i`（インサート）
  - `い` → `a`（アペンド）
  - `え` → `e`（行末移動）
  - `お` → `o`（新しい行）
  - `っd` → `dd`（行削除）
- `x` → ブラックホールレジスタに削除
- `<BS>` → VSCodeの削除機能
- `<Enter>` → 新しい行を挿入
- `>`, `<` → インデント調整

**ビジュアルモード:**
- `p` → ペーストして元の選択をyank
- `<Enter>` → ビジュアルモードを抜ける

### プラグイン機能

- **nvim-surround**: `ysiw"` などのsurround機能
- **CamelCaseMotion**: CamelCaseでの単語移動
- **targets.vim**: 拡張テキストオブジェクト
- **vim-sneak**: 2文字検索（f/F/t/Tを置き換え）
- **ReplaceWithRegister**: レジスタでの置換
- **vim-visual-star-search**: ビジュアル選択での検索
- **fastfold**: fold機能の最適化

### その他の機能

- **自動入力切り替え**: ノーマルモードに戻る際にim-selectで英語入力に切り替え
- **highlighted yank**: yank時の一時的なハイライト表示
- **日本語括弧**: 「」、（）、【】の対応

## トラブルシューティング

### プラグインが動作しない場合

```bash
# Neovimでプラグインを手動インストール
nvim +Lazy
```

### im-selectが動作しない場合

```bash
# im-selectをインストール
brew install im-select
```

### キーマッピングが効かない場合

VSCodeのVSCode Neovim拡張機能が有効になっており、`vim.neovimUseConfigFile`が`true`に設定されていることを確認してください。

## ファイル構成

```
~/.config/nvim/
├── init.lua                        # メイン設定ファイル
├── lua/
│   ├── vscode-neovim.lua          # VSCode Neovim専用設定 (最新API活用)
│   ├── vscode-composite-keys.lua  # Composite Key設定 [新規]
│   └── plugins/
│       └── vscode-plugins.lua      # VSCode用プラグイン設定 (最適化済み)
└── ...

~/.config/
├── vscode-neovim-settings.json    # VSCode設定テンプレート
└── vscode-neovim-setup.md         # セットアップガイド
```

## ヘルプコマンド

- `<leader>vk` → Composite Keyヘルプ表示
- `<leader>vcj` → Composite Key設定をクリップボードにコピー

## 最新の変更点 (2025年)

1. **API更新**: `vim.fn.VSCodeNotify()` → `vscode.action()`
2. **パフォーマンス**: `event = "VeryLazy"` → `lazy = false`
3. **新機能**: Composite Key、VSCode設定連携、高度なコマンド連携
4. **通知**: `print()` → `vscode.notify()`