return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          cmd = { "/etc/profiles/per-user/null0x/bin/marksman" },
        },
      },
      setup = {
        marksman = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
  { -- emphasized headers & code blocks
    "lukas-reineke/headlines.nvim",
    ft = "markdown", -- can work in other fts, but I only use it in markdown
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      markdown = {
        fat_headlines = false,
        dash_string = "─",
      },
    },
  },
  { -- auto-bullets for markdown-like filetypes
    "dkarter/bullets.vim",
    keys = {
      { "o", "<Plug>(bullets-newline)", ft = "markdown" },
      { "<CR>", "<Plug>(bullets-newline)", mode = "i", ft = "markdown" },
      { "<C-Tab>", "<Plug>(bullets-demote)", mode = { "i", "n", "x" }, ft = "markdown" },
      { "<S-Tab>", "<Plug>(bullets-promote)", mode = { "i", "n", "x" }, ft = "markdown" },
    },
    init = function()
      vim.g.bullets_set_mappings = 0 -- using my own
      vim.g.bullets_delete_last_bullet_if_empty = 1
      vim.g.bullets_enable_in_empty_buffers = 0
    end,
  },
  { -- preview markdown
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    -- ft-load-trigger needed for the plugin to work, even though it's only
    -- loaded on the keymap, probably the plugin has some ftplugin conditions
    -- or something.
    ft = "markdown",
    keys = {
      { "<leader>lmp", vim.cmd.MarkdownPreview, ft = "markdown", desc = " Preview" },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "marksman",
        "markdownlint",
      })
    end,
  },
}
