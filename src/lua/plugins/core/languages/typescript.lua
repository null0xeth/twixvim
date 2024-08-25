local filetypes = {
  "typescript",
  "typescriptreact",
  "javascript",
  "javascriptreact",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "typescript",
        "tsx",
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server",
        "js-debug-adapter",
        "deno",
        "eslint_d",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, {
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
      })
    end,
  },
  {
    "axelvc/template-string.nvim",
    ft = filetypes,
    opts = {},
  },
  {
    "marilari88/twoslash-queries.nvim",
    ft = filetypes,
    opts = {
      highlight = "Type",
      multi_line = true,
    },
  },
  {
    -- TODO: Fix on attach, maybe add lspconfig
    "pmizio/typescript-tools.nvim",
    ft = filetypes,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
      --"williamboman/mason.nvim",
    },
    config = function()
      require("typescript-tools").setup({
        on_attach = function(_, bufnr)
          local keymapcontroller = require("framework.controller.keymapcontroller"):new()
          keymapcontroller:register_whichkey({
            ["<leader>lt"] = { "+Typescript" },
          })
          -- stylua: ignore
          local maps = {
            { "n", "<leader>lto", "<cmd>TSToolsOrganizeImports<cr>", { buffer = bufnr, desc = "Organize Imports" } },
            { "n", "<leader>ltO", "<cmd>TSToolsSortImports<cr>", { buffer = bufnr, desc = "Sort Imports" } },
            { "n", "<leader>ltu", "<cmd>TSToolsRemoveUnused<cr>", { buffer = bufnr, desc = "Removed Unused" } },
            { "n", "<leader>ltz", "<cmd>TSToolsGoToSourceDefinition<cr>", { buffer = bufnr, desc = "Go To Source Definition" } },
            { "n", "<leader>ltR", "<cmd>TSToolsRemoveUnusedImports<cr>", { buffer = bufnr, desc = "Removed Unused Imports" } },
            { "n", "<leader>ltF", "<cmd>TSToolsFixAll<cr>", { buffer = bufnr, desc = "Fix All" } },
            { "n", "<leader>ltA", "<cmd>TSToolsAddMissingImports<cr>", { buffer = bufnr, desc = "Add Missing Imports" } },
          }

          keymapcontroller:batch_register_keymaps(maps, #maps)
        end,

        settings = {
          -- tsserver_path = tsserver_path .. "/node_modules/typescript/lib/tsserver.js",
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused" },
          tsserver_max_memory = 4096, -- 4096 | "auto"
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "literal",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    --"rcarriga/nvim-dap-ui",
    opts = {
      setup = {
        vscode_js_debug = function()
          local function get_js_debug()
            local install_path = require("mason-registry").get_package("js-debug-adapter"):get_install_path()
            return install_path .. "/js-debug/src/dapDebugServer.js"
          end

          for _, adapter in ipairs({
            "pwa-node",
            "pwa-chrome",
            "pwa-msedge",
            "node-terminal",
            "pwa-extensionHost",
          }) do
            require("dap").adapters[adapter] = {
              type = "server",
              host = "localhost",
              port = "${port}",
              executable = {
                command = "node",
                args = {
                  get_js_debug(),
                  "${port}",
                },
              },
            }
          end

          for _, language in ipairs({ "typescript", "javascript" }) do
            require("dap").configurations[language] = {
              {
                type = "pwa-node",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                cwd = "${workspaceFolder}",
              },
              {
                type = "pwa-node",
                request = "attach",
                name = "Attach",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
              },
              {
                type = "pwa-node",
                request = "launch",
                name = "Debug Jest Tests",
                -- trace = true, -- include debugger info
                runtimeExecutable = "node",
                runtimeArgs = {
                  "./node_modules/jest/bin/jest.js",
                  "--runInBand",
                },
                rootPath = "${workspaceFolder}",
                cwd = "${workspaceFolder}",
                console = "integratedTerminal",
                internalConsoleOptions = "neverOpen",
              },
              {
                type = "pwa-chrome",
                name = "Attach - Remote Debugging",
                request = "attach",
                program = "${file}",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                protocol = "inspector",
                port = 9222, -- Start Chrome google-chrome --remote-debugging-port=9222
                webRoot = "${workspaceFolder}",
              },
              {
                type = "pwa-chrome",
                name = "Launch Chrome",
                request = "launch",
                url = "http://localhost:5173", -- This is for Vite. Change it to the framework you use
                webRoot = "${workspaceFolder}",
                userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
              },
            }
          end

          for _, language in ipairs({ "typescriptreact", "javascriptreact" }) do
            require("dap").configurations[language] = {
              {
                type = "pwa-chrome",
                name = "Attach - Remote Debugging",
                request = "attach",
                program = "${file}",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                protocol = "inspector",
                port = 9222, -- Start Chrome google-chrome --remote-debugging-port=9222
                webRoot = "${workspaceFolder}",
              },
              {
                type = "pwa-chrome",
                name = "Launch Chrome",
                request = "launch",
                url = "http://localhost:5173", -- This is for Vite. Change it to the framework you use
                webRoot = "${workspaceFolder}",
                userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
              },
            }
          end
        end,
      },
    },
  },
  {
    "neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "thenbe/neotest-playwright",
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require("neotest-jest"),
        require("neotest-vitest"),
        require("neotest-playwright").adapter({
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
          },
        }),
      })
    end,
  },
}
