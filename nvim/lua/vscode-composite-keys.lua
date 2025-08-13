-- VSCode Neovim用 Composite Key設定
-- VSCodeのsettings.jsonに設定するcomposite keyの定義をここで管理

-- VSCode環境でのみ実行
if not vim.g.vscode then
  return
end

local vscode = require('vscode')

-- Composite Keyのヘルパー関数
local function setup_composite_keys()
  -- 設定説明用の通知
  vscode.notify('Composite Key設定が有効になりました。VSCodeのsettings.jsonに以下を追加してください:', 1)
  
  -- 推奨設定をクリップボードにコピー
  local composite_config = [[
{
  "vscode-neovim.compositeKeys": {
    "jj": {
      "command": "vscode-neovim.escape"
    },
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
      "args": [
        [
          "local vscode = require('vscode')",
          "vscode.action('workbench.action.quickOpen')"
        ]
      ]
    },
    ",,": {
      "command": "vscode-neovim.lua",
      "args": [
        [
          "local vscode = require('vscode')",
          "vscode.action('workbench.action.showCommands')"
        ]
      ]
    }
  }
}
]]
  
  -- 設定をクリップボードにコピー
  vscode.eval('await vscode.env.clipboard.writeText(args.text)', {
    args = { text = composite_config }
  })
  
  vscode.notify('Composite Key設定がクリップボードにコピーされました!', 1)
end

-- 初期化
setup_composite_keys()

-- ヘルプ機能
vim.keymap.set('n', '<leader>vk', function()
  vscode.notify([[
Composite Key機能:
- jj: エスケープ
- jk: エスケープ + 保存
- kj: エスケープ + フォーマット
- ;;: ファイル検索
- ,,: コマンドパレット

これらを使用するには、VSCodeのsettings.jsonに設定を追加する必要があります。
<leader>vc でコピーした設定を貼り付けてください。
]], 1)
end, { noremap = true, silent = true, desc = "Composite Key ヘルプ" })

-- 設定再コピー機能
vim.keymap.set('n', '<leader>vcj', setup_composite_keys, {
  noremap = true,
  silent = true,
  desc = "Composite Key設定をクリップボードにコピー"
})

return {
  setup = setup_composite_keys
}