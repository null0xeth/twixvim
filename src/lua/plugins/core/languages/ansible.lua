local function polish()
  local function yaml_ft(path, bufnr)
    -- get content of buffer as string
    local content = vim.filetype.getlines(bufnr)
    if type(content) == "table" then
      content = table.concat(content, "\n")
    end

    -- check if file is in roles, tasks, or handlers folder
    local path_regex = vim.regex("(tasks\\|roles\\|inventory\\|handlers)/")
    if path_regex and path_regex:match_str(path) then
      return "ansible"
    end
    -- check for known ansible playbook text and if found, return yaml.ansible
    local regex = vim.regex("hosts:\\|tasks:")
    if regex and regex:match_str(content) then
      return "ansible"
    end

    -- return yaml if nothing else
    return "yaml"
  end

  vim.filetype.add({
    extension = {
      yml = yaml_ft,
      yaml = yaml_ft,
    },
  })
end

local spec = {
  {
    "pearofducks/ansible-vim",
    ft = "ansible",
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
            "ansible",
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
                },
              },
            },
          },
        },
      },
      setup = {
        ansiblels = function(_, opts)
          polish()
          local lspcontroller = require("framework.controller.lspController"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
}

return spec
