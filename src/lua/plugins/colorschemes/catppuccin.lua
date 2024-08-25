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
        alpha = true,

        barbecue = {
          dim_dirname = true,
          bold_basename = true,
          dim_context = true,
          alt_background = false,
        },

        colorful_winsep = {
          enabled = false,
          color = "red",
        },
        dashboard = false,
        diffview = false,
        dropbar = false,
        feline = false,
        fidget = true,
        flash = false,
        fzf = true,
        gitsigns = true,
        grug_far = false,
        harpoon = false,
        headlines = false,
        hop = false,
        indent_blankline = {
          enabled = true,
          scope_color = "flamingo",
          colored_indent_levels = false,
        },
        leap = false,
        lightspeed = false,
        lir = {
          enabled = false,
          git_status = false,
        },
        lsp_saga = true,
        markdown = true,
        mason = true,
        mini = {
          enabled = true,
          indentscope_color = "lavender",
        },
        neotree = true,
        neogit = false,
        neotest = true,
        noice = true,
        NormalNvim = true,
        notifier = false,
        cmp = true,
        dap = true,
        dap_ui = true,

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
          inlay_hints = {
            background = true,
          },
        },
        navic = {
          enabled = false,
          custom_bg = "NONE", -- custom_bg = "NONE"
        },
        notify = true,
        semantic_tokens = true,
        nvim_surround = true,
        nvimtree = false,
        treesitter_context = true,
        treesitter = true,
        ufo = true,
        window_picker = true,
        octo = false,
        overseer = true,
        pounce = false,
        rainbow_delimiters = false,
        render_markdown = false,
        symbols_outline = true, --symbols-outline.nvim <- install dis
        telekasten = false,
        telescope = { enabled = true },
        lsp_trouble = true,
        dadbod_ui = false,
        illuminate = {
          enabled = true,
          lsp = true,
        },
        sandwich = false,
        vim_sneak = false,
        vimwiki = false,
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
