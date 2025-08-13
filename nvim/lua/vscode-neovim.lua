-- VSCode Neovim用設定ファイル
-- VSCodeVim拡張機能の設定をNeovimに移植

-- VSCode用の設定のみを実行
if vim.g.vscode then
  -- VSCode APIの読み込み
  local vscode = require('vscode')
  -- 基本設定
  vim.g.mapleader = " " -- Leader keyを設定
  
  -- 検索設定
  vim.opt.hlsearch = true      -- 検索結果をハイライト
  vim.opt.ignorecase = true    -- 大文字小文字を無視
  vim.opt.incsearch = true     -- インクリメンタル検索
  vim.opt.smartcase = true     -- 大文字が含まれている場合は大文字小文字を区別
  
  -- その他設定
  vim.opt.scroll = 5           -- スクロール行数
  vim.opt.clipboard = "unnamedplus" -- システムクリップボード使用
  
  -- matchpairsの設定（日本語括弧も含む）
  vim.opt.matchpairs = "(:),{:},[:],<:>,「:」,（:）,【:】"
  
  -- 日本語入力切り替え（im-selectを使用）
  local function switch_input_method()
    vim.fn.system("/opt/homebrew/bin/im-select com.apple.keylayout.ABC")
  end
  
  -- ノーマルモードに入る時に入力モードを英語に切り替え
  vim.api.nvim_create_autocmd({"InsertLeave"}, {
    callback = switch_input_method
  })
  
  -- キーマッピング設定
  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(mode, lhs, rhs, opts)
  end
  
  -- インサートモードのキーバインド
  -- jj, kk でエスケープ
  map("i", "jj", "<Esc>", { noremap = true, silent = true })
  map("i", "kk", "<Esc>", { noremap = true, silent = true })
  
  -- インサートモードでのCtrl+j/k（*/#検索）
  map("i", "<C-j>", "<Esc>*i", { noremap = true, silent = true })
  map("i", "<C-k>", "<Esc>#i", { noremap = true, silent = true })
  
  -- インサートモードでのCtrl+i（ysiw）- surround機能
  map("i", "<C-i>", "<Esc>ysiw", { noremap = true, silent = true })
  
  -- インサートモードでのCtrl+v（ビジュアルモード）
  map("i", "<C-v>", "<Esc>v", { noremap = true, silent = true })
  
  -- ノーマルモードのキーバインド
  -- Ctrl+j/k での*/#検索
  map("n", "<C-j>", "*", { noremap = true, silent = true })
  map("n", "<C-k>", "#", { noremap = true, silent = true })
  
  -- Ctrl+i での ysiw（surround機能）
  map("n", "<C-i>", "ysiw", { noremap = true, silent = true })
  
  -- 日本語キーでのバインド（ひらがな→英字）
  map("n", "あ", "i", { noremap = false, silent = true })
  map("n", "い", "a", { noremap = false, silent = true })
  map("n", "え", "e", { noremap = false, silent = true })
  map("n", "お", "o", { noremap = false, silent = true })
  map("n", "っd", "dd", { noremap = false, silent = true })
  
  -- VSCodeコマンド連携機能
    -- バックスペースでVSCodeの削除機能
    map("n", "<BS>", function()
      vscode.action('deleteLeft')
    end, { noremap = true, silent = true })
    
    -- エンターで新しい行を挿入
    map("n", "<CR>", function()
      vscode.action('editor.action.insertLineAfter')
    end, { noremap = true, silent = true })
    
    -- インデント調整
    map("n", ">", function()
      vscode.action('editor.action.indentLines')
    end, { noremap = true, silent = true })
    
    map("n", "<", function()
      vscode.action('editor.action.outdentLines')
    end, { noremap = true, silent = true })
  -- x での削除をブラックホール レジスタに送る
  map("n", "x", '"_x', { noremap = true, silent = true })
  
  -- ビジュアルモードのキーバインド
  -- p でペーストした後に元の選択範囲を再選択してyank
  map("v", "p", "pgvy", { noremap = true, silent = true })
  
  -- エンターでビジュアルモードを抜ける
  map("v", "<CR>", "<Esc>", { noremap = true, silent = true })
  
  -- EasyMotion風の動作（VSCodeのeasymotion拡張機能を使用）
  map("n", "<leader><leader>w", function()
    vscode.action('extension.vim-easymotion.word')
  end, { noremap = true, silent = true })
  
  map("n", "<leader><leader>b", function()
    vscode.action('extension.vim-easymotion.b')
  end, { noremap = true, silent = true })
  
  -- Ctrl+f でのEasyMotion
  map("n", "<C-f>", function()
    vscode.action('extension.vim-easymotion.bd-w')
  end, { noremap = true, silent = true })
  
  -- 追加のVSCode連携機能
  -- フォーマット機能（= キー）
  map("x", "=", function()
    vscode.call('editor.action.formatSelection')
  end, { noremap = true, silent = true })
  
  map("n", "=", function()
    vscode.call('editor.action.formatSelection')
  end, { noremap = true, silent = true })
  
  map("n", "==", function()
    vscode.call('editor.action.formatSelection')
  end, { noremap = true, silent = true })
  
  -- 定義を新しいパネルで開く
  map("n", "<C-w>gd", function()
    vscode.action('editor.action.revealDefinitionAside')
  end, { noremap = true, silent = true })
  
  -- カーソル下の単語でファイル検索
  map("n", "?", function()
    vscode.action('workbench.action.findInFiles', {
      args = { query = vim.fn.expand('<cword>') }
    })
  end, { noremap = true, silent = true })
  
  -- リファクタリング機能
  map({"n", "x"}, "<leader>r", function()
    vscode.with_insert(function()
      vscode.action('editor.action.refactor')
    end)
  end, { noremap = true, silent = true })
  
  -- 次の一致を選択（Ctrl+D）
  map({"n", "x", "i"}, "<C-d>", function()
    vscode.with_insert(function()
      vscode.action('editor.action.addSelectionToNextFindMatch')
    end)
  end, { noremap = true, silent = true })
  
  -- VSCode設定の取得・更新機能
  -- タブサイズを取得
  map("n", "<leader>vt", function()
    local tab_size = vscode.get_config('editor.tabSize')
    print('Current tab size: ' .. tab_size)
  end, { noremap = true, silent = true })
  
  -- フォントファミリーとタブサイズを一度に取得
  map("n", "<leader>vc", function()
    local configs = vscode.get_config({'editor.fontFamily', 'editor.tabSize'})
    vim.print(configs)
  end, { noremap = true, silent = true })
  
  -- VSCodeでのJavaScript実行例
  map("n", "<leader>vf", function()
    local current_file = vscode.eval('return vscode.window.activeTextEditor.document.fileName')
    print('Current file: ' .. current_file)
  end, { noremap = true, silent = true })
  
  -- クリップボードにテキストを書き込み
  map("n", "<leader>vy", function()
    local text = vim.fn.expand('<cword>')
    vscode.eval('await vscode.env.clipboard.writeText(args.text)', {
      args = { text = text }
    })
    print('Copied to clipboard: ' .. text)
  end, { noremap = true, silent = true })
  
  -- highlighted yank 機能の模倣（VSCodeのハイライト機能を活用）
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank({
        higroup = "IncSearch",
        timeout = 1500,
      })
    end,
  })
  
  -- VSCodeの通知機能を使用
  vscode.notify('VSCode Neovim設定が読み込まれました', 1) -- Info level
  
  -- vim.notifyをVSCodeの通知で置き換え
  vim.notify = vscode.notify
  
  -- Composite Key設定の読み込み
  require('vscode-composite-keys')
end