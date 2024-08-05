local config = require("config")

local spec = {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { [[<C-\>]] },
      { "<leader>vt", "<Cmd>2ToggleTerm<Cr>", desc = "Terminal" },
    },
    opts = {
      --size = 25,
      size = function(term)
        if term.direction == "horizontal" then
          return vim.o.lines / 2
        elseif term.direction == "vertical" then
          return vim.o.columns / 2
        end
      end,

      hide_numbers = true, --true
      open_mapping = [[<C-\>]],
      shade_filetypes = {},
      shade_terminals = true, --false
      shading_factor = 1, -- 0.3
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "horizontal",
      close_on_exit = false,
      auto_scroll = false,
      autchdir = false,
      winbar = {
        enabled = false,
        name_formatter = function(term)
          return term.name
        end,
      },
    },
  },
  {
    "tzachar/highlight-undo.nvim",
    keys = { "u", "U" },
    opts = {
      duration = 250,
      undo = {
        lhs = "u",
        map = "silent undo",
        opts = { desc = "󰕌 Undo" },
      },
      redo = {
        lhs = "U",
        map = "silent redo",
        opts = { desc = "󰑎 Redo" },
      },
    },
  },
  {
    "cshuaimin/ssr.nvim",
    enabled = false,
    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
      keymaps = {
        close = "q",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<leader><cr>",
      },
    },
    keys = {
      {
        "<leader>srr",
        function()
          require("ssr").open()
        end,
        mode = { "n", "x" },
        desc = "Search and Replace (SSR)",
      },
    },
  },
  { -- refactoring utilities
    "ThePrimeagen/refactoring.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = true,
    keys = {
			-- stylua: ignore start
			{"<leader>ri", function() require("refactoring").refactor("Inline Variable") end,  desc = "󱗘 Inline Var (Refactoring)" },
			{"<leader>re", function() require("refactoring").refactor("Extract Variable") end, desc = "󱗘 Extract Var (Refactoring)" },
			{"<leader>ru", function() require("refactoring").refactor("Extract Function") end, desc = "󱗘 Extract Func (Refactoring)" },
      -- stylua: ignore end
    },
  },
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>sst", function() require("spectre").toggle() end, desc = "Toggle (Spectre)" },
      { '<leader>ssw', function() require("spectre").open_visual({select_word=true}) end, desc = "Search Current Word (Spectre)" },
      { '<leader>ssv', function() require("spectre").open_visual() end, desc = "Open Visual Panel (Spectre)" },
      { '<leader>ssv', function() require("spectre").open_file_search({select_word=true}) end, desc = "Search in File (Spectre)" },
    },
  },
  {
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
  {
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
  {
    "folke/which-key.nvim",
    event = "KindaLazy",
    opts = {
      setup = {
        triggers_blacklist = { i = { "<C-G>" } },
        plugins = {
          presets = { motions = false, g = false, z = false },
          spelling = { enabled = false },
        },
        -- hidden = { "<Plug>", "^:lua ", "<cmd>" },
        -- key_labels = {
        --   ["<CR>"] = "↵",
        --   ["<BS>"] = "⌫",
        --   ["<space>"] = "󱁐",
        --   ["<Tab>"] = "󰌒",
        ["<Esc>"] = "⎋",
      },
      --key_labels = { ["<leader>"] = "SPC" },
      --triggers = "auto",
      win = {
        -- border = "single", -- none, single, double, shadow
        -- position = "bottom", -- bottom, top
        -- margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        -- padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
        -- winblend = 0,
      },
      popup_mappings = {
        scroll_down = "<PageDown>",
        scroll_up = "<PageUp>",
      },
      layout = {
        -- height = { min = 4, max = 25 }, -- min and max height of the columns
        -- width = { min = 20, max = 50 }, -- min and max width of the columns
        -- spacing = 1, -- spacing between columns
        --[[           align = "left", -- align columns left, center or right ]]
      },

      defaults = config.keymap_categories,
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts.setup)
      wk.register(opts.defaults)
    end,
  },
  {
    "allaman/kustomize.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = "yaml",
    opts = {
      enable_key_mappings = true,
      enable_lua_snip = true,
      validate = { kubeconform_args = { "--strict", "--ignore-missing-schemas" } },
      build = {
        additional_args = { "--enable-helm", "--load-restrictor=LoadRestrictionsNone" },
      },
      deprecations = { kube_version = "1.25" },
      kinds = { show_filepath = true, show_line = true, exclude_pattern = "" },
    },
  },
}

return spec
