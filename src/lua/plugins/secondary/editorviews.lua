local spec = {
  {
    "dnlhc/glance.nvim",
    cmd = { "Glance" },
    keys = {
      { "<leader>lgr", "<cmd>Glance references<cr>", desc = "(Glance) LSP References" },
      { "<leader>lgd", "<cmd>Glance definitions<cr>", desc = "(Glance) LSP Definitions" },
      { "<leader>lgi", "<cmd>Glance implementations<cr>", desc = "(Glance) LSP Implementations" },
      { "<leader>lgt", "<cmd>Glance type_definitions<cr>", desc = "(Glance) LSP Type Definitiions" },
    },
    config = function()
      local lspcontroller = require("framework.controller.lspcontroller"):new()
      lspcontroller:setup_glance()
    end,
  },
  {
    -- code outline
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
          "numToStr/Comment.nvim",
          "nvim-telescope/telescope.nvim",
        },
        opts = { lsp = { auto_attach = true } },
      },
    },
    --stylua: ignore
    keys = {
      { "<leader>vO", function() require("nvim-navbuddy").open() end, desc = "Code Outline (navbuddy)", },
    },
  },
  { -- symbols sibebar and search
    "stevearc/aerial.nvim",
    event = "KindaLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>lct", "<cmd>AerialToggle<CR>", desc = "Toggle LSP Symbols Sidebar (Aerial)" },
      { "<leader>lcn", "<cmd>AerialNavToggle<CR>", desc = "Toggle LSP Symbols Nav Window (Aerial)" },
      { "<C-j>", "<cmd>AerialNext<CR>zv", desc = "󰒕 Next Symbol" },
      { "<C-k>", "<cmd>AerialPrev<CR>zv", desc = "󰒕 Previous Symbol" },
      {
        "gs",
        function()
          require("telescope").load_extension("aerial")
          require("telescope").extensions.aerial.aerial()
        end,
        desc = "󰒕 Symbols Search",
      },
    },
    opts = {
      close_on_select = true,
      link_folds_to_tree = true,
      show_guides = true,
      highlight_on_hover = true,
      layout = {
        default_direction = "right",
        min_width = { 20, 0.2 },
        max_width = 0.35,
        win_opts = { winhighlight = "Normal:NormalFloat" },
      },
      icons = { Collapsed = "" },
      -- stylua: ignore
      guides = {
          mid_item   = "├╴",
          last_item  = "└╴",
          nested_top = "│ ",
          whitespace = "  ",
      },
      keymaps = {
        -- instead of `autojump = true`, using these to only move when
        -- navigating within the symbol sidebar
        ["<Tab>"] = "actions.down_and_scroll",
        ["<S-Tab>"] = "actions.up_and_scroll",
        ["j"] = "actions.down_and_scroll",
        ["k"] = "actions.up_and_scroll",
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    enabled = false,
    tag = "legacy",
    event = { "LspAttach" },
    config = function()
      local fidget = require("fidget")
      fidget.setup({
        window = {
          blend = 0,
        },
        text = {
          spinner = "dots",
          done = "",
          commenced = "",
          completed = "",
        },
        fmt = {
          stack_upwards = false,
        },
      })
    end,
  },
  {
    "nvimdev/lspsaga.nvim",
    enabled = false,
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local catppuccin = function()
        local cachecontroller = require("framework.controller.cachecontroller"):new()
        local config = cachecontroller:query("colorschemes")
        if config[1] == "catppuccin" then
          local _kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind()
          local ui = {
            kind = _kind,
          }
          return ui
        else
          return {}
        end
      end
      require("lspsaga").setup({
        symbol_in_winbar = {
          enable = false,
        },
        lightbulb = {
          enable = false,
        },
        ui = catppuccin(),
      })
    end,
  },
  {
    "echasnovski/mini.map",
    opts = true,
    keys = {
      --stylua: ignore
      { "<leader>vm", function() require("mini.map").toggle {} end, desc = "Toggle Minimap" },
    },
    config = function(_, opts)
      require("mini.map").setup(opts)
    end,
  },
  {
    "hedyhli/outline.nvim",
    keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    cmd = "Outline",
    opts = function()
      local defaults = require("outline.config").defaults
      local opts = {
        symbols = {},
        keymaps = {
          up_and_jump = "<up>",
          down_and_jump = "<down>",
        },
      }
      return opts
    end,
  },
}

return spec
