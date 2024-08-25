local keymap = vim.keymap.set
local api = vim.api

local spec = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "ron",
        "rust",
        "toml",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { rust = { "rustfmt" } })
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "codelldb",
        "taplo",
      },
    },
  },
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        "nvim-lua/plenary.nvim",
        "mfussenegger/nvim-dap",
      },
    },
    config = function()
      local lspcontroller = require("framework.controller.lspcontroller"):new()
      local dapcontroller = require("framework.controller.dapcontroller"):new()
      local rtools = require("rust-tools") ---@module 'rust-tools'
      local rust_adapter = dapcontroller:get_rust_adapter()
      local opts = {
        tools = {
          hover_actions = {
            border = "solid",
            auto_focus = true,
          },
          on_initialized = function()
            api.nvim_create_autocmd(
              { "BufEnter", "CursorHold", "InsertLeave" },
              { pattern = "*.rs", callback = vim.lsp.codelens.refresh }
            )
          end,
          inlay_hints = {
            auto = true,
          },
        },
        server = {
          standalone = true,
          capabilities = lspcontroller:get_capabilities(), --lsphandler.capabilities(),
          root_dir = require("lspconfig.util").root_pattern("Cargo.toml"),
          on_attach = function(client, bufnr)
            keymap("n", "<leader>rc", "<Nop>", { desc = "+Crates" })
            if client.name == "rust_analyzer" then
              local wk = require("which-key")
              local keys = {
                mode = { "n", "v" },
                ["<leader>r"] = { name = "+Rust" },
              }
              wk.register(keys)
              -- stylua: ignore
              keymap("n", "<leader>r", "<Nop>", { desc = "+Rust" })
              keymap("n", "<leader>re", function()
                rtools.runnables.runnables()
              end, { desc = "Runnables" })
              keymap("n", "<leader>rl", function()
                vim.lsp.codelens.run()
              end, { desc = "Code Lens" })
              keymap("n", "<leader>rm", function()
                rtools.expand_macro.expand_macro()
              end, { desc = "Expand Macro (Recursively)" })
              keymap("n", "<leader>rt", "<cmd>Cargo test<cr>", { desc = "Cargo test" })
              keymap("n", "<leader>rR", "<cmd>Cargo run<cr>", { desc = "Cargo run" })
              keymap("n", ";h", rtools.hover_actions.hover_actions, { buffer = bufnr })
              keymap("n", ";c", rtools.code_action_group.code_action_group, { buffer = bufnr })
              keymap("n", "<leader>ri", "<Nop>", { desc = "+Inlay Hints" })
              keymap("n", "<leader>rie", function()
                rtools.inlay_hints.enable()
              end, { desc = "Set Inlay Hints (All Buf)" })
              keymap("n", "<leader>rid", function()
                rtools.inlay_hints.disable()
              end, { desc = "Unset Inlay Hints (All Buf)" })
              keymap("n", "<leader>ris", function()
                rtools.inlay_hints.set()
              end, { desc = "Set Inlay Hints (Current Buf)" })
              keymap("n", "<leader>riu", function()
                rtools.inlay_hints.unset()
              end, { desc = "Unset Inlay Hints (Current Buf)" })
            end
          end,

          --cmd = { "/etc/profiles/per-user/null0x/bin/rust-analyzer" },
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Add clippy lints for Rust.
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        dap = {
          adapter = rust_adapter,
        },
      }
      rtools.setup(opts)
      --end)()
    end,
  },
  -- {
  --   "mfussenegger/nvim-dap",
  --   optional = true,
  --   opts = {
  --     setup = {
  --       codelldb = function()
  --         vim.schedule_wrap(function()
  --           local dapcontroller = require("framework.controller.dapcontroller"):new()
  --           dapcontroller:setup_rust_dap()
  --         end)()
  --       end,
  --     },
  --   },
  -- },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "rust-lang/rust.vim" },
    },
    opts = {
      servers = {
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      },
      -- setup = {
      --   taplo = function(_, opts)
      --     vim.schedule_wrap(function()
      --       local function show_documentation()
      --         if fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
      --           require("crates").show_popup()
      --         else
      --           vim.lsp.buf.hover()
      --         end
      --       end

      --       local function taplo_attach(client, buffer)
      --         if client.name == "taplo" then
      --           keymap("n", "K", function()
      --             show_documentation()
      --           end, { buffer = buffer, desc = "Show Crate Documentation" })
      --         end
      --       end

      --       local lspcontroller = require("dev.controller.lspController"):new()
      --       lspcontroller:setup_lsp_servers(_, opts, taplo_attach)
      --       --return false -- make sure the base implementation calls taplo.setup
      --     end)()
      --   end,
      -- },
    },
  },
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.schedule_wrap(function()
        local completion_interface = require("framework.interfaces.completion_interface"):new()

        completion_interface:setup_crates()
      end)()
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "rouge8/neotest-rust",
    },
    opts = function(_, opts)
      opts.adapters = vim.list_extend(opts.adapters, { require("neotest-rust") })
    end,
  },
}

return spec
