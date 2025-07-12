-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- UI設定
vim.g.snacks_animate = false
vim.opt.relativenumber = true  -- 相対行番号を有効化（より効率的な移動のため）
vim.opt.helplang = "ja"

-- パフォーマンス設定
vim.opt.updatetime = 200  -- CursorHoldイベントの発火時間を短縮
vim.opt.timeoutlen = 300  -- マッピングのタイムアウトを短縮

-- アンドゥ履歴の永続化
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- スワップファイルとバックアップの管理
vim.opt.swapfile = true
vim.opt.backup = false
vim.opt.writebackup = true
local swapdir = vim.fn.stdpath("data") .. "/swap"
if vim.fn.isdirectory(swapdir) == 0 then
  vim.fn.mkdir(swapdir, "p")
end
vim.opt.directory = swapdir

-- 検索設定の改善
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- スクロール設定
vim.opt.scrolloff = 8  -- 上下に常に8行表示
vim.opt.sidescrolloff = 8  -- 左右に常に8文字表示

-- 分割ウィンドウの挙動
vim.opt.splitbelow = true
vim.opt.splitright = true

-- タブとインデント
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- 折りたたみ設定
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-- その他の便利な設定
vim.opt.clipboard = "unnamedplus"  -- システムクリップボードを使用
vim.opt.mouse = "a"  -- マウスサポート
vim.opt.termguicolors = true  -- True Color対応
