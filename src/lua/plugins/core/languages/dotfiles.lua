return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, {
        ["_"] = { "trim_whitespace" },
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- move dis to other langs
      opts.linters_by_ft["sh"] = { "shellcheck" }
    end,
  },
  {
    "luckasRanarison/tree-sitter-hypr",
    event = "BufRead */hypr/*.conf",
    config = function()
      -- Fix ft detection for hyprland
      vim.filetype.add({
        pattern = { [".*/hypr/.*%.conf"] = "hypr" },
      })
      require("nvim-treesitter.parsers").get_parser_configs().hypr = {
        install_info = {
          url = "https://github.com/luckasRanarison/tree-sitter-hypr",
          files = { "src/parser.c" },
          branch = "master",
        },
        filetype = "hypr",
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "git_config",
        "rasi",
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.hadolint, -- dockerfile
        nls.builtins.diagnostics.actionlint, --github actions
        nls.builtins.diagnostics.checkmake, --check makefiles
        nls.builtins.diagnostics.gitlint, --git
        nls.builtins.diagnostics.zsh, --zsh

        -- move
        nls.builtins.formatting.packer, --hcp packer
        nls.builtins.formatting.prettierd, --prettierd
        nls.builtins.formatting.pg_format, --pgsql
        nls.builtins.formatting.shfmt, --bash
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        dockerls = {
          cmd = {
            "docker-langserver",
            "--stdio",
          },
          settings = {},
        },
        bashls = {},
      },
      setup = {
        dockerls = function(_, opts)
          local lspcontroller = require("framework.controller.lspController"):new()
          lspcontroller:setup_lsp_servers(_, opts.dockerls)
        end,
        bashls = function(_, opts)
          local lspcontroller = require("framework.controller.lspController"):new()
          lspcontroller:setup_lsp_servers(_, opts.bashls)
        end,
      },
    },
  },
}
