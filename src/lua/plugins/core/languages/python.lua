return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "debugpy",
        "black",
        "ruff",
        "autoflake",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { python = { "isort", "black" } })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft["python"] = { "flake8" }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {},
      },
      setup = {
        ruff_lsp = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts, function(client, _)
            if client.name == "ruff_lsp" then
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
          end)
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                typeCheckingMode = "off",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly", -- "openFilesOnly" or "openFilesOnly"
                stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs/stubs",
              },
            },
          },
        },
      },
      setup = {
        pyright = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts, function(client, bufnr)
            local map = function(mode, lhs, rhs, desc)
              if desc then
                desc = desc
              end
              vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
            end
            -- stylua: ignore
            if client.name == "pyright" then
              map("n", "<leader>lo", "<cmd>PyrightOrganizeImports<cr>", "Organize Imports")
              map("n", "<leader>lC", function() require("dap-python").test_class() end, "Debug Class")
              map("n", "<leader>lM", function() require("dap-python").test_method() end, "Debug Method")
              map("v", "<leader>lE", function() require("dap-python").debug_selection() end, "Debug Selection")
            end
          end)
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    --"rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      config = function()
        local path = require("mason-registry").get_package("debugpy"):get_install_path()
        require("dap-python").setup(path .. "/venv/bin/python")
      end,
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "unittest",
        }),
      })
    end,
  },
  {
    "microsoft/python-type-stubs",
    cond = false,
  },
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    opts = {},
    keys = { { "<leader>lv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" } },
  },
}
