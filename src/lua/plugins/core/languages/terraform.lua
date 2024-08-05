local spec = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "terraform",
        "hcl",
      })
    end,
  },
  {
  "williamboman/mason.nvim",
  opts = { ensure_installed = { "tflint" } },
},
  -- {
  --   -- add Terragrunt
  --   "stevearc/conform.nvim",
  --   opts = function(_, opts)
  --     opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, {
  --       ["terraform"] = { "terraform_fmt" },
  --     })
  --   end,
  -- },
  {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
    },
  },
},
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.terraform_fmt,
        nls.builtins.diagnostics.terraform_validate,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        terraformls = {
          filetypes = {
            "terraform",
            "terraform-vars",
          },
          cmd = {
            "terraform-ls",
            "serve",
          },
          settings = {},
        },
      },
      setup = {
        terraformls = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
}

return spec
