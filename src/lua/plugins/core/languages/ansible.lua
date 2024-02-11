return {
  {
    "pearofducks/ansible-vim",
    event = "KindaLazy",
  },

  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.ansiblelint, -- ansible
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        ansiblels = {
          filetypes = {
            "yaml.ansible",
          },
          cmd = {
            "ansible-language-server",
            "--stdio",
          },
          settings = {
            ansible = {
              validation = {
                enabled = true,
                lint = {
                  enabled = true,
                  path = "ansible-lint",
                },
              },
            },
          },
        },
      },
      setup = {
        ansiblels = function(_, opts)
          local lspcontroller = require("framework.controller.lspController"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
}
