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
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { css = { "prettierd" } })
    end,
  },
}

return spec
