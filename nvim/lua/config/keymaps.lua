-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--っｊでノーマルモードに移行する
vim.keymap.set("i", "jj", "<ESC>", { silent = true })
vim.keymap.set("i", "っｊ", "<ESC>", { silent = true })

-- Git Explorer keymaps
vim.keymap.set("n", "<leader>eg", function()
  require("snacks").explorer({
    filter = { git_modified = true }
  })
end, { desc = "Explorer: Git modified files only" })

vim.keymap.set("n", "<leader>es", function()
  require("snacks").explorer({
    filter = { git_staged = true }
  })
end, { desc = "Explorer: Git staged files only" })

vim.keymap.set("n", "<leader>eu", function()
  require("snacks").explorer({
    filter = { git_untracked = true }
  })
end, { desc = "Explorer: Git untracked files only" })

vim.keymap.set("n", "<leader>ea", function()
  require("snacks").explorer({
    filter = { git_modified = true, git_staged = true, git_untracked = true }
  })
end, { desc = "Explorer: All git changed files" })

-- バッファ操作
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer", silent = true })
vim.keymap.set("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force delete buffer", silent = true })

-- ウィンドウ操作（Ctrl+hjklでウィンドウ間移動）
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window", silent = true })

-- ウィンドウリサイズ
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

-- ターミナルモードからの脱出
vim.keymap.set("t", "<C-\\><C-n>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- 検索ハイライト解除
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

-- 行の移動（Visual modeでも使用可能）
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- インデント調整後も選択を維持
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Yを行末までヤンクに変更（Vimの標準的な動作）
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- センターカーソルでスクロール
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- クイックフィックスリスト操作
vim.keymap.set("n", "<leader>qo", ":copen<CR>", { desc = "Open quickfix list", silent = true })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix list", silent = true })
vim.keymap.set("n", "[q", ":cprevious<CR>", { desc = "Previous quickfix item", silent = true })
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix item", silent = true })
