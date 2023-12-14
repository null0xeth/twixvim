local spec = {
  {
    "Catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    event = "VimEnter",
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      term_colors = true,
      integrations = {
        aerial = true,
        neotree = true,
        mini = {
          enabled = true,
          indentscope_color = "lavender", -- catppuccin color (eg. `lavender`) Default: text
        },
        barbecue = {
          dim_dirname = true,
          bold_basename = true,
          dim_context = true,
          alt_background = false,
        },
        dashboard = true,
        fidget = true,
        gitsigns = true,
        indent_blankline = {
          enabled = true,
          --scope_color = "flamingo",
          colored_indent_levels = false,
        },
        lsp_saga = true,
        markdown = true,
        mason = true,
        neogit = true,
        neotest = true,
        noice = true,
        cmp = true, -- nvim-cmp
        dap = { -- nvim-dap / nvim-dap-ui
          enabled = true,
          enable_ui = true,
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
          -- inlay_hints = {
          --   background = true,
          -- },
        },
        navic = {
          enabled = true,
          custom_bg = "NONE", -- custom_bg = "NONE"
        },
        notify = true,
        semantic_tokens = true,
        nvimtree = true,
        treesitter = true,
        overseer = true,
        symbols_outline = true, --symbols-outline.nvim <- install dis
        telescope = { enabled = true },
        lsp_trouble = true,
        illuminate = {
          enabled = true,
          lsp = true,
        },
        which_key = true,
      },
    },

    config = function(_, opts)
      vim.schedule_wrap(function()
        require("catppuccin").setup(opts)
        vim.opt.termguicolors = true
        vim.cmd.colorscheme("catppuccin")
      end)()
    end,
  },
}

return spec
