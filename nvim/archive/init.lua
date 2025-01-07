-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Plugin setup
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('vim-jp/vimdoc-ja')

Plug('nvim-lualine/lualine.nvim')
Plug('nvim-tree/nvim-web-devicons')

Plug('/usr/local/opt/fzf')
Plug('junegunn/fzf.vim')

vim.api.nvim_set_keymap('n', '[Fzf]', '<Nop>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>f', '[Fzf]', {})
vim.api.nvim_set_keymap('n', '[Fzf]f', ':Files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '[Fzf]g', ':GFiles<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '[Fzf]G', ':GFiles?<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '[Fzf]b', ':Buffers<CR>', { noremap = true })

Plug('lambdalisue/fern.vim')

Plug('nvim-treesitter/nvim-treesitter')

Plug ('nvim-lua/plenary.nvim')
Plug ('nvim-telescope/telescope.nvim')

Plug('https://github.com/tpope/vim-commentary')
Plug('https://github.com/simeji/winresizer.git')
vim.g.winresizer_start_key = '<C-w>'
vim.g.winresizer_keycode_cancel = 122

Plug('https://github.com/preservim/vim-indent-guides.git')
vim.g.indent_guides_enable_on_vim_startup = 1

Plug ('williamboman/mason.nvim')
Plug ('williamboman/mason-lspconfig.nvim')
Plug ('neovim/nvim-lspconfig')

Plug ('hrsh7th/cmp-nvim-lsp')
Plug ('hrsh7th/cmp-buffer')
Plug ('hrsh7th/cmp-path')
Plug ('hrsh7th/cmp-cmdline')
Plug ('hrsh7th/nvim-cmp')

Plug('github/copilot.vim')
vim.call('plug#end')

-- Settings
vim.opt.clipboard:append{'unnamedplus'}
vim.o.syntax = 'on'
vim.o.showmode = true
vim.o.expandtab = true
vim.o.number = true
vim.o.tabstop = 2
vim.o.list = true
vim.o.autoindent = true
vim.o.cursorline = true
vim.cmd('highlight CursorLine ctermfg=Blue ctermbg=Green')
vim.o.termguicolors = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.autochdir = true
-- vim.o.statusline = '%F'
vim.o.helplang = 'ja,en'
vim.o.mouse = ''

vim.opt.matchpairs:append({ '「:」', '（:）', '【:】' })

-- Key Mappings
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true })
vim.api.nvim_set_keymap('x', 'd', '"_d', { noremap = true })
vim.api.nvim_set_keymap('x', 'p', '"_dP', { noremap = true })

vim.api.nvim_set_keymap('n', 'x', '"_x', { noremap = true })
vim.api.nvim_set_keymap('n', 'X', '"_D', { noremap = true })
vim.api.nvim_set_keymap('x', 'x', '"_x', { noremap = true })

vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })
vim.api.nvim_set_keymap('o', 'i<space>', 'iW', { noremap = true })
vim.api.nvim_set_keymap('x', 'i<space>', 'iW', { noremap = true })

vim.api.nvim_set_keymap('n', 'U', '<c-r>', { noremap = true })
vim.api.nvim_set_keymap('n', 'M', '%', { noremap = true })

-- Insert mode mappings
vim.api.nvim_set_keymap('i', '<C-j>', '<Esc>*i', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<Esc>#i', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-i>', '<Esc>ysiw', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-y>', '<Esc>yss', { noremap = true })
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('i', 'kk', '<Esc>', { noremap = true })

-- Other key mappings
vim.api.nvim_set_keymap('n', '<ESC><ESC>', ':nohlsearch<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'ss', '^', { noremap = true })

vim.api.nvim_set_keymap('n', '<BS>', 'X', { noremap = true })
vim.api.nvim_set_keymap('n', '<Enter>', 'o<Esc>', { noremap = true })
vim.api.nvim_set_keymap('n', '>', '>>', { noremap = true })
vim.api.nvim_set_keymap('n', '<', '<<', { noremap = true })

vim.api.nvim_set_keymap('n', 'J', '10j', { noremap = true })
vim.api.nvim_set_keymap('n', 'K', '10k', { noremap = true })
vim.api.nvim_set_keymap('n', 'gl', 'gt', { noremap = true })
vim.api.nvim_set_keymap('n', 'gh', 'gT', { noremap = true })
vim.api.nvim_set_keymap('n', 'gk', ':tabedit<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'gj', ':bdelete<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', 'gJ', ':bdelete!<CR>', { noremap = true })

-- Additional settings
vim.api.nvim_set_keymap('v', ',', '<ESC>ggVG', { noremap = true })
vim.api.nvim_set_keymap('t', '<space>jj', '<C-\\><C-n>', { noremap = true })

vim.cmd('command! SS :so %')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-e>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<C-g>', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<C-f>', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>eh', builtin.help_tags, { desc = 'Telescope help tags' })
-- lua-line setup
require('lualine').setup({
  options = {
    theme = 'auto',
    section_separators = { '', '' },
    component_separators = { '', '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
})

-- Mason setup
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require("mason-lspconfig").setup()
--
-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- fern.vim
vim.api.nvim_set_keymap('n', '<Leader>e', '<Cmd>Fern . -drawer<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>E', '<Cmd>Fern . -drawer -reveal=%<CR>', { noremap = true, silent = true })

-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "typescript",
    "tsx",
    "go",
    "rust",
    "lua",
    "json",
    "yaml",
    "html",
    "css",
    "scss",
    "sql",
    "tmux",
    "javascript",
    "bash",
    "python",
    "c",
    "vim",
    "php",
    "gomod",
    "nginx",
    "terraform",
    "vue",
    "prisma",
    "csv",
  },
  highlight = {
    enable = true,
  },
}
