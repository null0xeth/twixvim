local config = require("config")

local spec = {
  {
    "altermo/iedit.nvim",
    event = "KindaLazy",
    config = function()
      require("iedit").setup()
    end,
  },
  {
    "numToStr/FTerm.nvim",
    event = "KindaLazy",
    keys = {
      {
        "<c-/>",
        function()
          require("FTerm").toggle()
        end,
      },
    },
    config = function()
      require("FTerm").setup({
        border = "double",
        dimensions = {
          height = 0.9,
          width = 0.9,
        },
      })
    end,
  },
  {
    -- Looks for .nvim/deployment.lua in root of pproject
    "coffebar/transfer.nvim",
    enabled = false,
    event = "KindaLazy",
    cmd = { "TransferInit", "DiffRemote", "TransferUpload", "TransferDownload", "TransferDirDiff", "TransferRepeat" },
    config = function()
      require("which-key").add({
        { "<leader>u", group = "Upload / Download", icon = "" },
        {
          "<leader>ud",
          "<cmd>TransferDownload<cr>",
          desc = "Download from remote server (scp)",
          icon = { color = "green", icon = "󰇚" },
        },
        {
          "<leader>uf",
          "<cmd>DiffRemote<cr>",
          desc = "Diff file with remote server (scp)",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>ui",
          "<cmd>TransferInit<cr>",
          desc = "Init/Edit Deployment config",
          icon = { color = "green", icon = "" },
        },
        {
          "<leader>ur",
          "<cmd>TransferRepeat<cr>",
          desc = "Repeat transfer command",
          icon = { color = "green", icon = "󰑖" },
        },
        {
          "<leader>uu",
          "<cmd>TransferUpload<cr>",
          desc = "Upload to remote server (scp)",
          icon = { color = "green", icon = "󰕒" },
        },
      })
    end,
  },
  {
    "gbprod/substitute.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      on_substitute = nil,
      yank_substituted_text = true,
      preserve_cursor_position = true,
      modifiers = nil,
      highlight_substituted_text = {
        enabled = true,
        timer = 500,
      },
      range = {
        prefix = "s",
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        subject = nil,
        range = nil,
        suffix = "",
        auto_apply = false,
        cursor_position = "end",
      },
      exchange = {
        motion = false,
        use_esc_to_cancel = true,
        preserve_cursor_position = false,
      },
    },
  },
  {
    "s1n7ax/nvim-comment-frame",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      {
        "<leader>cbs",
        function()
          require("nvim-comment-frame").add_comment()
        end,
        desc = "Add single-line commentbox",
        mode = { "n" },
      },
      {
        "<leader>cbm",
        function()
          require("nvim-comment-frame").add_multiline_comment()
        end,
        desc = "Add multi-line commentbox",
        mode = { "n" },
      },
    },
    config = function()
      require("nvim-comment-frame").setup({

        -- if true, <leader>cf keymap will be disabled
        disable_default_keymap = false,

        -- adds custom keymap
        keymap = "<leader>cc",
        multiline_keymap = "<leader>cm",

        -- start the comment with this string
        start_str = "//",

        -- end the comment line with this string
        end_str = "//",

        -- fill the comment frame border with this character
        fill_char = "-",

        -- width of the comment frame
        frame_width = 70,

        -- wrap the line after 'n' characters
        line_wrap_len = 50,

        -- automatically indent the comment frame based on the line
        auto_indent = true,

        -- add comment above the current line
        add_comment_above = true,

        -- configurations for individual language goes here
        languages = {
          lua = {
            -- start the comment with this string
            start_str = "--[[",

            -- end the comment line with this string
            end_str = "]]--",

            -- fill the comment frame border with this character
            fill_char = "*",

            -- width of the comment frame
            frame_width = 100,

            -- wrap the line after 'n' characters
            line_wrap_len = 70,

            -- automatically indent the comment frame based on the line
            auto_indent = true,

            -- add comment above the current line
            add_comment_above = false,
          },
        },
      })
    end,
  },
  {
    "ray-x/sad.nvim",
    event = "KindaLazy",
    dependencies = { "ray-x/guihua.lua" },
    config = function()
      require("sad").setup({
        debug = false,
        diff = "diff-so-fancy",
        ls_file = "fd",
        exact = false,
        vsplit = true,
      })
    end,
  },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<leader>fs",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
    config = function()
      require("rip-substitute").setup({
        popupWin = {
          title = " rip-substitute",
          border = "single",
          matchCountHlGroup = "Keyword",
          noMatchHlGroup = "ErrorMsg",
          hideSearchReplaceLabels = false,
          ---@type "top"|"bottom"
          position = "bottom",
        },
        prefill = {
          ---@type "cursorWord"| false
          normal = "cursorWord",
          ---@type "selectionFirstLine"| false does not work with ex-command (see README).
          visual = "selectionFirstLine",
          startInReplaceLineIfPrefill = false,
        },
        keymaps = { -- normal & visual mode, if not stated otherwise
          abort = "q",
          confirm = "<CR>",
          insertModeConfirm = "<C-CR>",
          prevSubst = "<Up>",
          nextSubst = "<Down>",
          toggleFixedStrings = "<C-f>", -- ripgrep's `--fixed-strings`
          toggleIgnoreCase = "<C-c>", -- ripgrep's `--ignore-case`
          openAtRegex101 = "R",
        },
        incrementalPreview = {
          matchHlGroup = "IncSearch",
          rangeBackdrop = {
            enabled = true,
            blend = 50, -- between 0 and 100
          },
        },
        regexOptions = {
          startWithFixedStringsOn = false,
          startWithIgnoreCase = false,
          -- pcre2 enables lookarounds and backreferences, but performs slower
          pcre2 = true,
          -- disable if you use named capture groups (see README for details)
          autoBraceSimpleCaptureGroups = true,
        },
        editingBehavior = {
          -- When typing `()` in the `search` line, automatically adds `$n` to the
          -- `replace` line.
          autoCaptureGroups = false,
        },
        notificationOnSuccess = true,
      })
    end,
  },
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
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.grug_far({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },
  -- {
  --   "cshuaimin/ssr.nvim",
  --   enabled = false,
  --   opts = {
  --     border = "rounded",
  --     min_width = 50,
  --     min_height = 5,
  --     max_width = 120,
  --     max_height = 25,
  --     keymaps = {
  --       close = "q",
  --       next_match = "n",
  --       prev_match = "N",
  --       replace_confirm = "<cr>",
  --       replace_all = "<leader><cr>",
  --     },
  --   },
  --   keys = {
  --     {
  --       "<leader>srr",
  --       function()
  --         require("ssr").open()
  --       end,
  --       mode = { "n", "x" },
  --       desc = "Search and Replace (SSR)",
  --     },
  --   },
  -- },
  -- { -- refactoring utilities
  --   "ThePrimeagen/refactoring.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  --   opts = true,
  --   keys = {
  -- 	-- stylua: ignore start
  -- 	{"<leader>ri", function() require("refactoring").refactor("Inline Variable") end,  desc = "󱗘 Inline Var (Refactoring)" },
  -- 	{"<leader>re", function() require("refactoring").refactor("Extract Variable") end, desc = "󱗘 Extract Var (Refactoring)" },
  -- 	{"<leader>ru", function() require("refactoring").refactor("Extract Function") end, desc = "󱗘 Extract Func (Refactoring)" },
  --     -- stylua: ignore end
  --   },
  -- },
  -- {
  --   "nvim-pack/nvim-spectre",
  --   build = false,
  --   cmd = "Spectre",
  --   opts = { open_cmd = "noswapfile vnew" },
  --   -- stylua: ignore
  --   keys = {
  --     { "<leader>sst", function() require("spectre").toggle() end, desc = "Toggle (Spectre)" },
  --     { '<leader>ssw', function() require("spectre").open_visual({select_word=true}) end, desc = "Search Current Word (Spectre)" },
  --     { '<leader>ssv', function() require("spectre").open_visual() end, desc = "Open Visual Panel (Spectre)" },
  --     { '<leader>ssv', function() require("spectre").open_file_search({select_word=true}) end, desc = "Search in File (Spectre)" },
  --   },
  -- },
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
    opts_extend = { "spec" },
    opts = {
      defaults = {},
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
