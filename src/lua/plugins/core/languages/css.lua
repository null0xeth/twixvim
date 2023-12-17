local spec = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {
          cmd = {
            "vscode-css-language-server",
            "--stdio",
          },
          settings = {},
        },
      },
      setup = {
        cssls = function(_, opts)
          local lspcontroller = require("framework.controller.lspController"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.stylelint,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { css = { "prettierd" } })
    end,
  },
}

return spec
