return {
  -- add yaml specific modules to treesitter
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "yamlfmt",
        "yamllint",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "yaml",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { yaml = { "prettierd" } })
      opts.formatters =
        vim.tbl_deep_extend("force", opts.formatters, { prettierd = {
          range_args = false,
        } })
    end,
  },
  -- {
  --   "mfussenegger/nvim-lint",
  --   opts = function(_, opts)
  --     opts.linters_by_ft["yaml"] = { "yamllint" }
  --   end,
  -- },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.yamllint,
        nls.builtins.formatting.yamlfix, --yaml
        nls.builtins.formatting.yamlfmt, --yaml
      })
    end,
  },

  {
    "someone-stole-my-name/yaml-companion.nvim",
    ft = { "yaml" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      local telescopecontroller = require("framework.controller.telescopecontroller"):new()
      telescopecontroller:load_extension("yaml_schema")
    end,
  },
  {
    "cuducos/yaml.nvim",
    ft = { "yaml" }, -- optional
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "someone-stole-my-name/yaml-companion.nvim",
      {
        "b0o/SchemaStore.nvim",
        version = false,
      },
    },
    opts = {
      -- make sure mason installs the server
      servers = {
        yamlls = {
          filetypes = {
            "yaml",
          },
          cmd = {
            "yaml-language-server",
            "--stdio",
          },
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas()
            )
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              validate = true,
              format = { enable = false },
              hover = true,
              schemaStore = {
                enable = false,
                url = "",
              },
              schemaDownload = { enable = true },
              schemas = {},
              trace = { server = "debug" },
              keyordering = false,
            },
          },
        },
      },
      setup = {
        yaml_ls = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts, function(client, _)
            if client.name == "yamlls" then
              client.server_capabilities.documentFormattingProvider = true
            end
          end)
        end,
      },
    },
  },
}
