return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- LSP診断の設定をカスタマイズ
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●", -- アイコンを変更
          source = "if_many", -- 複数のソースがある場合のみソースを表示
          spacing = 2,
        },
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
        signs = true,
        underline = true,
        update_in_insert = false, -- インサートモード中は更新しない（パフォーマンス向上）
        severity_sort = true, -- 重要度でソート
      })

      -- LSPサーバーの設定をカスタマイズ
      local servers = opts.servers or {}
      
      -- TypeScript/JavaScriptの設定
      if servers.ts_ls then
        servers.ts_ls.settings = servers.ts_ls.settings or {}
        servers.ts_ls.settings.typescript = servers.ts_ls.settings.typescript or {}
        servers.ts_ls.settings.typescript.inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      end

      -- Rustの設定
      if servers.rust_analyzer then
        servers.rust_analyzer.settings = servers.rust_analyzer.settings or {}
        servers.rust_analyzer.settings["rust-analyzer"] = {
          inlayHints = {
            bindingModeHints = {
              enable = false,
            },
            chainingHints = {
              enable = true,
            },
            closingBraceHints = {
              enable = true,
              minLines = 25,
            },
            closureReturnTypeHints = {
              enable = "never",
            },
            lifetimeElisionHints = {
              enable = "never",
              useParameterNames = false,
            },
            maxLength = 25,
            parameterHints = {
              enable = true,
            },
            reborrowHints = {
              enable = "never",
            },
            renderColons = true,
            typeHints = {
              enable = true,
              hideClosureInitialization = false,
              hideNamedConstructor = false,
            },
          },
        }
      end

      -- Lua LSPの設定
      if servers.lua_ls then
        servers.lua_ls.settings = servers.lua_ls.settings or {}
        servers.lua_ls.settings.Lua = servers.lua_ls.settings.Lua or {}
        servers.lua_ls.settings.Lua.hint = {
          enable = true,
          paramType = true,
          paramName = "Disable", -- "All" | "Literal" | "Disable"
          semicolon = "Disable", -- "All" | "SameLine" | "Disable"
          arrayIndex = "Disable", -- "Enable" | "Auto" | "Disable"
        }
      end

      return opts
    end,
    init = function()
      -- インレイヒントを有効化
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })

      -- LSPログレベルを設定（デバッグ時に有用）
      -- vim.lsp.set_log_level("debug")
    end,
  },
  
  -- インレイヒントのトグル機能を追加
  {
    "neovim/nvim-lspconfig",
    keys = {
      {
        "<leader>uh",
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
        end,
        desc = "Toggle Inlay Hints",
      },
    },
  },
}