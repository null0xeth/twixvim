local vim = vim
local fn = vim.fn
local api = vim.api

local spec = {
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "honza/vim-snippets",
        config = function()
          require("luasnip.loaders.from_snipmate").lazy_load()
          require("luasnip").filetype_extend("all", { "_" })
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<C-j>",
        function()
          return require("luasnip").jumpable() and require("luasnip").jump_next() or "<C-j>"
        end,
        expr = true,
        remap = true,
        silent = true,
        mode = "i",
      },
      {
        "<C-j>",
        function()
          require("luasnip").jump(1)
        end,
        mode = "s",
      },
      {
        "<C-k>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = {
          "i",
          "s",
        },
      },
    },
    -- TODO: revisit this config
    config = function(_, opts)
      require("luasnip").setup(opts)

      local snippets_folder = fn.stdpath("config") .. "/lua/plugins/core/completion/snippets/"
      require("luasnip.loaders.from_lua").lazy_load({ paths = snippets_folder })

      api.nvim_create_user_command("LuaSnipEdit", function()
        require("luasnip.loaders.from_lua").edit_snippet_files()
      end, {})
    end,
  },
  {
    "danymat/neogen",
    cmd = { "Neogen" },
    opts = {
      snippet_engine = "luasnip",
      enabled = true,
      languages = {
        lua = {
          template = {
            annotation_convention = "ldoc",
          },
        },
        python = {
          template = {
            annotation_convention = "google_docstrings",
          },
        },
        rust = {
          template = {
            annotation_convention = "rustdoc",
          },
        },
        javascript = {
          template = {
            annotation_convention = "jsdoc",
          },
        },
        typescript = {
          template = {
            annotation_convention = "tsdoc",
          },
        },
        typescriptreact = {
          template = {
            annotation_convention = "tsdoc",
          },
        },
      },
    },
    --stylua: ignore
    keys = {
      { "<leader>laa", function() require("neogen").generate() end,                  desc = "Annotation (Neogen)", },
      { "<leader>lac", function() require("neogen").generate { type = "class" } end, desc = "Class (Neogen)", },
      { "<leader>laf", function() require("neogen").generate { type = "func" } end,  desc = "Function (Neogen)", },
      { "<leader>lat", function() require("neogen").generate { type = "type" } end,  desc = "Type (Neogen)", },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
      "dmitmel/cmp-cmdline-history",
      "hrsh7th/cmp-nvim-lua",
      "petertriho/cmp-git",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "SergioRibera/cmp-dotenv",
    },
    config = function()
      local completion_controller = require("framework.controller.completioncontroller"):new()
      completion_controller:initialize_cmp()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        disable_filetype = {
          "TelescopePrompt",
          "vim",
        },
      })
    end,
  },
}

return spec
