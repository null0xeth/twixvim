return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "helm-ls",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        helm_ls = {},
      },
      setup = {
        helm_ls = function(_, opts)
          vim.schedule_wrap(function()
            local lspcontroller = require("framework.controller.lspcontroller"):new()
            lspcontroller:setup_lsp_servers(_, opts)
          end)()
        end,
      },
    },
  },
}
