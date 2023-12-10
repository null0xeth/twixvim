-- local log = require("util.logger"):new()
-- log:start_timer("coding_plugins")

local config = require("config")

-- coding
local spec = {
  { --done
    "echasnovski/mini.indentscope",
    version = false,
    event = "KindaLazy",
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      local autocmdcontroller = require("framework.controller.autocmdcontroller"):new()
      autocmdcontroller:add_autocmd({
        event = "FileType",
        pattern = {
          "aerial",
          "help",
          "dashboard",
          "NvimTree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
        },
        command_or_callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  { -- done
    "ghillb/cybu.nvim",
    keys = {
      {
        "<BS>",
        function()
          require("cybu").cycle("prev")
        end,
        desc = "󰽙 Prev Buffer",
      },
      {
        "<Tab>",
        "<Plug>(CybuNext)",
        desc = "󰽙 Next Buffer",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
    opts = {
      display_time = 1000,
      position = {
        anchor = "bottomcenter",
        max_win_height = 12,
        vertical_offset = 3,
      },
      style = {
        border = "rounded",
        padding = 7,
        path = "tail",
        hide_buffer_id = true,
        highlights = { current_buffer = "CursorLine", adjacent_buffers = "Normal" },
      },
      behavior = {
        mode = {
          default = { switch = "immediate", view = "paging" },
        },
      },
    },
  },
  { -- automatically set correct indent for file done
    "nmac427/guess-indent.nvim",
    event = "BufReadPre",
    opts = {
      -- due to code blocks and bullets often having spaces or tabs
      filetype_exclude = { "markdown", "aerial" },
    },
  },
  { -- auto-close inactive buffers done
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    opts = {
      retirementAgeMins = 10,
      ignoreUnsavedChangesBufs = false,
      notificationOnAutoClose = true,
      deleteBufferWhenFileDeleted = true,
    },
  },
  { -- fixes scrolloff at end of file done
    "Aasim-A/scrollEOF.nvim",
    event = "CursorMoved",
    opts = true,
  },
  { --done
    "folke/which-key.nvim",
    event = "KindaLazy",
    opts = {
      setup = {
        triggers_blacklist = { i = { "<C-G>" } },
        plugins = {
          presets = { motions = false, g = false, z = false },
          spelling = { enabled = false },
        },
        hidden = { "<Plug>", "^:lua ", "<cmd>" },
        key_labels = {
          ["<CR>"] = "↵",
          ["<BS>"] = "⌫",
          ["<space>"] = "󱁐",
          ["<Tab>"] = "󰌒",
          ["<Esc>"] = "⎋",
        },
        --key_labels = { ["<leader>"] = "SPC" },
        --triggers = "auto",
        window = {
          border = "single", -- none, single, double, shadow
          position = "bottom", -- bottom, top
          margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
          padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
          winblend = 0,
        },
        popup_mappings = {
          scroll_down = "<PageDown>",
          scroll_up = "<PageUp>",
        },
        layout = {
          height = { min = 4, max = 25 }, -- min and max height of the columns
          width = { min = 20, max = 50 }, -- min and max width of the columns
          spacing = 1, -- spacing between columns
          align = "center", -- align columns left, center or right
        },
      },
      defaults = config.keymap_categories,
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts.setup)
      wk.register(opts.defaults)
    end,
  },
  { --done
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gcc", mode = { "n", "v" } },
      { "gbc", mode = { "n", "v" } },
    },
    config = function()
      require("Comment").setup({
        ignore = "^$",
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  { --done
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "UIEnter",
    config = function()
      require("ibl").setup({
        debounce = 1000,
        indent = {
          char = "│", -- spaces
          tab_char = "│", -- tabs
        },
        whitespace = { highlight = { "Whitespace", "NonText" } },
        scope = { enabled = false },
        exclude = {
          filetypes = {
            "aerial",
            "markdown",
            "vimwiki",
            "help",
            "dashboard",
            "NvimTree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lspinfo",
            "checkhealth",
            "TelescopePrompt",
            "TelescopeResults",
          },
        },
      })
    end,
  },
  { --done
    "chrisgrieser/nvim-origami",
    event = "KindaLazy",
    keys = {
      {
        "<leader>efl",
        function()
          require("origami").h()
        end,
        desc = "(Origami) Fold line",
      },
      {
        "<leader>efu",
        function()
          require("origami").l()
        end,
        desc = "(Origami) Unfold line",
      },
    },
    config = function()
      require("origami").setup({
        keepFoldsAcrossSessions = true,
        pauseFoldsOnSearch = true,
        setupFoldKeymaps = false,
      })
    end,
  },
  -- done
  { "tpope/vim-repeat", event = "KindaLazy" },
  { -- done
    "sustech-data/wildfire.nvim",
    event = "KindaLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("wildfire").setup()
    end,
  },
}

--log:stop_timer("coding_plugins")
return spec
