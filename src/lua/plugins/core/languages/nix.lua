return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "nix",
        "git_config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.code_actions.statix,
        nls.builtins.diagnostics.deadnix,
        nls.builtins.diagnostics.statix,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      --opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { nix = { "nixfmt" } })
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { nix = { "alejandra" } })
      --opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, { nix = { "nixpkgs_fmt" } })
    end,
  },
  -- {
  --   "mfussenegger/nvim-lint",
  --   opts = function(_, opts)
  --     opts.linters_by_ft["nix"] = { "statix" }
  --   end,
  -- },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "LnL7/vim-nix" },
    },
    opts = {
      servers = {
        nil_ls = {
          --cmd = { "/etc/profiles/per-user/null0x/bin/nil" },
          cmd = { "nil" },
          settings = {
            ["nil"] = {
              textSetting = 42,
              formatting = {
                command = { "alejandra" },
              },
              autoArchive = true,
            },
          },
        },
      },
      setup = {
        nil_ls = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
}
