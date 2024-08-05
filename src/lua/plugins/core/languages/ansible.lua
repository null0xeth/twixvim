local spec = {
  {
    "pearofducks/ansible-vim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    event = "KindaLazy",
    config = function()
      local autocmdcontroller = require("framework.controller.autocmdcontroller"):new()
      local augroup = autocmdcontroller:add_augroup("ansible", { clear = true })
      autocmdcontroller:add_autocmd({
        event = { "BufRead", "BufNewFile" },
        pattern = {
          "*/ansible/*.yml",
          "*/tasks/*.yml",
        },
        group = augroup,
        command_or_callback = function()
          vim.bo.filetype = "yaml.ansible"
        end,
      })
      autocmdcontroller:add_autocmd({
        event = { "BufRead", "BufNewFile" },
        pattern = {
          "*/ansible/inventory/*",
          "*/ansible/hosts-*",
        },
        group = augroup,
        command_or_callback = function()
          local filepath = vim.fn.expand("%:p")
          if filepath:match("%.yml$") then
            vim.bo.filetype = "yaml.ansible_hosts"
          else
            vim.bo.filetype = "ansible_hosts"
          end
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-ansible",
    ft = {},
    keys = {
      {
        "<leader>ta",
        function()
          require("ansible").run()
        end,
        desc = "Ansible Run Playbook/Role",
        silent = true,
      },
    },
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
                enabled = true,
                lint = {
                  enabled = true,
                },
              },
            },
          },
        },
      },
      setup = {
        ansiblels = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
}

return spec
