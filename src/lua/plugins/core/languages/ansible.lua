return {
  {
    "pearofducks/ansible-vim",
    event = "KindaLazy",
    config = function()
      local aucontroller = require("framework.controller.autocmdcontroller"):new()
      local augroup = aucontroller:add_augroup("ansible_yaml_ft", { clear = true })
      aucontroller:add_autocmd({
        event = { "KindaLazy" },
        pattern = {
          "*/ansible/*.yml",
          "*/inventory/*.yml",
          "*/tasks/*.yml",
        },
        group = augroup,
        command_or_callback = function()
          vim.bo.filetype = "ansible"
        end,
      })
    end,
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
            "ansible",
            "yaml.ansible",
            "yaml.ansible_hosts",
          },
          cmd = {
            "ansible-language-server",
            "--stdio",
          },
          settings = {
            ansible = {
              validation = {
                lint = {
                  enabled = false,
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
