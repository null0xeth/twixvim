local long_opts = { silent = true, expr = true, mode = { "i", "n", "s" } }

local spec = {
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "stevearc/stickybuf.nvim",
    enabled = false,
    event = "KindaLazy",
    config = function()
      require("stickybuf").setup({
        -- This function is run on BufEnter to determine pinning should be activated
        get_auto_pin = function(bufnr)
          -- You can return "bufnr", "buftype", "filetype", or a custom function to set how the window will be pinned.
          -- You can instead return an table that will be passed in as "opts" to `stickybuf.pin`.
          -- The function below encompasses the default logic. Inspect the source to see what it does.
          return require("stickybuf").should_auto_pin(bufnr)
        end,
      })
    end,
  },
  {
    "folke/noice.nvim",
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
      "nvim-treesitter/nvim-treesitter",
    },
    -- stylua: ignore
    keys = {
      { "<leader>unl", function() require("noice").cmd("last") end,    desc = "Last Message (Noice)" },
      { "<leader>unh", function() require("noice").cmd("history") end, desc = "History (Noice)", },
      { "<leader>una", function() require("noice").cmd("all") end, desc = "All (Noice)", },
      { "<leader>und", function() require("noice").cmd("dismiss") end, desc = "Dismiss All (Noice)", },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, long_opts, desc = "Scroll Forward" },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, long_opts,  desc = "Scroll backward", },
    },
    config = function()
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      local supportlibcontroller = require("framework.controller.supportlibcontroller"):new()
      supportlibcontroller:noice_setup()
    end,
  },
  {
    "stevearc/dressing.nvim",
    init = vim.schedule(function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end),
    config = function()
      require("dressing").setup({
        input = {
          enabled = true,
          default_prompt = ">",
          prompt_align = "left",
          insert_only = true,
          start_in_insert = true,
          border = "rounded",
          relative = "cursor",
          prefer_width = 10,
          width = nil,
          max_width = { 140, 0.9 },
          min_width = { 10, 0.1 },

          win_options = {
            winblend = 0,
            winhighlight = "",
          },

          mappings = {
            n = {
              ["q"] = "Close",
              ["<Esc>"] = "Close",
              ["<CR>"] = "Confirm",
            },
            i = {
              ["q"] = "Close",
              ["<Esc>"] = "Close",
              ["<CR>"] = "Confirm",
              ["<Up>"] = "HistoryPrev",
              ["<Down>"] = "HistoryNext",
            },
          },

          override = function(conf)
            return conf
          end,

          get_config = nil,
        },

        select = {
          -- Set to false to disable the vim.ui.select implementation
          enabled = true,

          -- Priority list of preferred vim.select implementations
          backend = { "telescope", "nui", "fzf", "builtin" },

          -- Options for nui Menu
          nui = {
            position = {
              row = 1,
              col = 0,
            },
            size = nil,
            relative = "cursor",
            border = {
              style = "rounded",
              text = {
                top_align = "right",
              },
            },
            buf_options = {
              swapfile = false,
              filetype = "DressingSelect",
            },
            max_width = 80,
            max_height = 40,
          },

          -- Options for built-in selector
          builtin = {
            -- These are passed to nvim_open_win
            wnchor = "SW",
            border = "rounded",
            -- 'editor' and 'win' will default to being centered
            relative = "cursor",

            win_options = {
              -- Window transparency (0-100)
              winblend = 5,
              -- Change default highlight groups (see :help winhl)
              winhighlight = "",
            },

            -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- the min_ and max_ options can be a list of mixed types.
            -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
            width = nil,
            max_width = { 140, 0.8 },
            min_width = { 10, 0.2 },
            height = nil,
            max_height = 0.9,
            min_height = { 2, 0.05 },

            -- Set to `false` to disable
            mappings = {
              ["<Esc>"] = "Close",
              ["q"] = "Close",
              ["<CR>"] = "Confirm",
            },

            override = function(conf)
              -- This is the config that will be passed to nvim_open_win.
              -- Change values here to customize the layout
              return conf
            end,
          },

          -- see :help dressing_get_config
          get_config = function(opts)
            if opts.kind == "codeaction" then
              return {
                backend = "builtin",
                nui = {
                  relative = "cursor",
                  max_width = 80,
                  min_height = 2,
                },
              }
            end
          end,
        },
      })
    end,
  },
  {
    "nvim-focus/focus.nvim",
    enabled = false,
    cmd = { "FocusSplitNicely", "FocusSplitLeft", "FocusSplitRight", "FocusSplitDown" },
    version = false,
    config = function()
      require("focus").setup({
        enable = true, -- Enable module
        commands = true, -- Create Focus commands
        autoresize = {
          enable = true, -- Enable or disable auto-resizing of splits
          -- width = 0, -- Force width for the focused window
          -- height = 0, -- Force height for the focused window
          -- minwidth = 0, -- Force minimum width for the unfocused window
          -- minheight = 0, -- Force minimum height for the unfocused window
          --height_quickfix = 10, -- Set the height of quickfix panel
        },
        split = {
          bufnew = false, -- Create blank buffer for new split windows
          tmux = false, -- Create tmux splits instead of neovim splits
        },
        ui = {
          number = false, -- Display line numbers in the focussed window only
          relativenumber = false, -- Display relative line numbers in the focussed window only
          hybridnumber = false, -- Display hybrid line numbers in the focussed window only
          absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

          cursorline = true, -- Display a cursorline in the focussed window only
          cursorcolumn = true, -- Display cursorcolumn in the focussed window only
          colorcolumn = {
            enable = false, -- Display colorcolumn in the foccused window only
            list = "+1", -- Set the comma-saperated list for the colorcolumn
          },
          --signcolumn = true, -- Display signcolumn in the focussed window only
          winhighlight = true, -- Auto highlighting for focussed/unfocussed windows
        },
      })
    end,
  },
  -- Fix bufferline offsets when edgy is loaded
  {
    "akinsho/bufferline.nvim",
    opts = function()
      local Offset = require("bufferline.offset")
      if not Offset.edgy then
        local get = Offset.get
        Offset.get = function()
          if package.loaded.edgy then
            local layout = require("edgy.config").layout
            local ret = { left = "", left_size = 0, right = "", right_size = 0 }
            for _, pos in ipairs({ "left", "right" }) do
              local sb = layout[pos]
              if sb and #sb.wins > 0 then
                local title = " Sidebar" .. string.rep(" ", sb.bounds.width - 8)
                ret[pos] = "%#EdgyTitle#" .. title .. "%*" .. "%#WinSeparator#│%*"
                ret[pos .. "_size"] = sb.bounds.width
              end
            end
            ret.total_size = ret.left_size + ret.right_size
            if ret.total_size > 0 then
              return ret
            end
          end
          return get()
        end
        Offset.edgy = true
      end
    end,
  },
  {
    --- [TODO:fix]
    "folke/edgy.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>uet",
        function()
          require("edgy").toggle()
        end,
        desc = "Edgy Toggle",
      },
      -- stylua: ignore
      { "<leader>ues", function() require("edgy").select() end, desc = "Edgy Select Window" },
    },
    opts = function()
      local opts = {
        bottom = {
          {
            ft = "toggleterm",
            size = { height = 0.4 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          {
            ft = "noice",
            size = { height = 0.25 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          "Trouble",
          {
            ft = "trouble",
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          { ft = "qf", title = "QuickFix" },
          {
            ft = "help",
            size = { height = 20 },
            -- don't open help files in edgy that we're editing
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
          { title = "Spectre", ft = "spectre_panel", size = { height = 0.4 } },
          { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
        },
        left = {
          {
            title = "Neo-Tree",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "filesystem"
            end,
            open = "Neotree",
            --pinned = true,
            size = {
              height = 0.5,
              width = 0.2,
            },
            wo = {
              winblend = 0,
              colorcolumn = "",
            },
          },
          {
            title = "Neo-Tree Buffers",
            ft = "neo-tree",
            size = { width = 0.2 },
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "buffers"
            end,
            pinned = true,
            open = "Neotree position=top buffers",
          },
          {
            title = "Neo-Tree Git",
            ft = "neo-tree",
            size = { width = 0.2 },
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "git_status"
            end,
            pinned = true,
            open = "Neotree position=right git_status",
          },
          {
            ft = "Outline",
            pinned = true,
            open = "SymbolsOutline",
          },
          "neo-tree",
        },
        right = {
          {
            title = "Outline (Aerial)",
            ft = "aerial",
            pinned = true,
            open = "AerialOpen",
            size = { height = 0.5 },
          },
        },
        options = {
          left = { size = 35 },
          bottom = { size = 15 },
          right = { size = 30 },
          top = { size = 15 },
        },
        -- edgebar animations
        animate = {
          enabled = true,
          fps = 100, -- frames per second
          cps = 120, -- cells per second
          on_begin = function()
            vim.g.minianimate_disable = true
          end,
          on_end = function()
            vim.g.minianimate_disable = false
          end,
          -- Spinner for pinned views that are loading.
          -- if you have noice.nvim installed, you can use any spinner from it, like:
          --spinner = require("noice.util.spinners").spinners.circleFull,
          spinner = {
            frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
            interval = 80,
          },
        },
        -- enable this to exit Neovim when only edgy windows are left
        exit_when_last = true,
        -- close edgy when all windows are hidden instead of opening one of them
        -- disable to always keep at least one edgy split visible in each open section
        close_when_all_hidden = true,
        -- global window options for edgebar windows
        ---@type vim.wo
        wo = {
          -- Setting to `true`, will add an edgy winbar.
          -- Setting to `false`, won't set any winbar.
          -- Setting to a string, will set the winbar to that string.
          winbar = true,
          winfixwidth = true,
          winfixheight = false,
          --winhighlight = "WinBar:EdgyWinBar,Normal:EdgyNormal",
          winhighlight = "WinBar:EdgyWinBar,NeoTreeStatusLineNC:EdgyWinBar,WinBarNC:EdgyWinBar,Normal:EdgyNormal",
          spell = false,
          --signcolumn = "auto:3",
        },
        keys = {
          -- increase width
          ["<c-Right>"] = function(win)
            win:resize("width", 2)
          end,
          -- decrease width
          ["<c-Left>"] = function(win)
            win:resize("width", -2)
          end,
          -- increase height
          ["<c-Up>"] = function(win)
            win:resize("height", 2)
          end,
          -- decrease height
          ["<c-Down>"] = function(win)
            win:resize("height", -2)
          end,
        },
        --fix_win_height = 0,
      }
      return opts
    end,
  },
}

return spec
