-- VSCode Neovim用プラグイン設定

-- VSCode環境でのみ有効にするプラグイン
if not vim.g.vscode then
  return {}
end

return {
    -- surround機能（ysiwなど）
    {
      "kylechui/nvim-surround",
      version = "*",
      lazy = false, -- VSCodeでは即座読み込み
      config = function()
        require("nvim-surround").setup({
          -- VSCode用の最適化設定
          keymaps = {
            insert = "<C-g>s",
            insert_line = "<C-g>S",
            normal = "ys",
            normal_cur = "yss",
            normal_line = "yS",
            normal_cur_line = "ySS",
            visual = "S",
            visual_line = "gS",
            delete = "ds",
            change = "cs",
          },
        })
      end,
    },
    
    -- camelCase motions
    {
      "bkad/CamelCaseMotion",
      lazy = false, -- VSCodeでは即座読み込み
      config = function()
        -- 元のモーションを保持しつつ、CamelCase版を追加
        vim.g.camelcasemotion_key = '<leader>'
        
        -- 新しいキーマッピング
        vim.keymap.set({"n", "v", "o"}, "<leader>w", "<Plug>CamelCaseMotion_w", { silent = true, desc = "CamelCase word forward" })
        vim.keymap.set({"n", "v", "o"}, "<leader>b", "<Plug>CamelCaseMotion_b", { silent = true, desc = "CamelCase word backward" })
        vim.keymap.set({"n", "v", "o"}, "<leader>e", "<Plug>CamelCaseMotion_e", { silent = true, desc = "CamelCase word end" })
        
        -- テキストオブジェクト
        vim.keymap.set({"n", "v", "o"}, "i<leader>w", "<Plug>CamelCaseMotion_iw", { silent = true, desc = "Inner CamelCase word" })
      end,
    },
    
    -- targets.vim（テキストオブジェクト拡張）
    {
      "wellle/targets.vim",
      lazy = false, -- VSCodeでは即座読み込み
    },
    
    -- vim-sneak（2文字検索）
    {
      "justinmk/vim-sneak",
      lazy = false, -- VSCodeでは即座読み込み
      config = function()
        vim.g["sneak#use_ic_scs"] = 1    -- ignorecase and smartcase
        vim.g["sneak#s_next"] = 1        -- sneak replaces f/F/t/T
        vim.g["sneak#label"] = 1         -- ラベルモードで高速化
        vim.g["sneak#target_labels"] = "sfnutaghmqvcpzxbeidkjyorwl"
        
        -- カスタムキーマッピング
        vim.keymap.set({"n", "x", "o"}, "f", "<Plug>Sneak_f", { silent = true })
        vim.keymap.set({"n", "x", "o"}, "F", "<Plug>Sneak_F", { silent = true })
        vim.keymap.set({"n", "x", "o"}, "t", "<Plug>Sneak_t", { silent = true })
        vim.keymap.set({"n", "x", "o"}, "T", "<Plug>Sneak_T", { silent = true })
      end,
    },
    
    -- ReplaceWithRegister
    {
      "vim-scripts/ReplaceWithRegister",
      lazy = false, -- VSCodeでは即座読み込み
    },
    
    -- ビジュアルスター（ビジュアル選択した文字列で検索）
    {
      "nelstrom/vim-visual-star-search",
      lazy = false, -- VSCodeでは即座読み込み
    },
    
    -- fold機能の修正（foldfix）
    {
      "konfekt/fastfold",
      lazy = false, -- VSCodeでは即座読み込み
      config = function()
        vim.g.fastfold_savehook = 1
        vim.g.fastfold_fold_command_suffixes = {'x','X','a','A','o','O','c','C','r','R','m','M','i','n','N'}
        vim.g.fastfold_fold_movement_commands = {'[z', ']z', 'zj', 'zk'}
        vim.g.fastfold_force = 1 -- VSCodeでのパフォーマンス最適化
      end,
    },
  }