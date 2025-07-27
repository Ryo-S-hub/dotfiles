return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    -- 👇 実際のキーマップをここに定義。LazyVimが自動でこれらのキーマップを登録する
    {
      "<leader>e",
      "<cmd>Yazi<cr>",
      desc = "ファイルマネージャー(yazi)を開く",
    },
    {
      -- カレントファイルを選択した状態でyaziを開く
      "<leader>-",
      "<cmd>Yazi cwd<cr>",
      desc = "カレントファイルでyaziを開く",
    },
  },
  opts = {
    -- Yaziを開く際のウィンドウサイズ設定
    open_for_directories = false, -- ディレクトリを開く際にyaziを使わない（必要に応じて変更）
    keymaps = {
      show_help = '<f1>',
    },
    -- yaziが選択したファイルをneovimで開く際の設定
    open_file_function = function(chosen_file, config, state)
      -- 標準的なファイルオープン機能
      vim.cmd(string.format("edit %s", vim.fn.fnameescape(chosen_file)))
    end,
    -- yaziが閉じた後にneovimにフォーカスを戻す
    set_keymappings_function = function(yazi_buffer_id, config, context)
      -- カスタムキーマップがあれば追加
    end,
  },
}