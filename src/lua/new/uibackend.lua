local long_opts = { silent = true, expr = true, mode = { "i", "n", "s" } }

local spec = {
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "folke/noice.nvim",
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
    opts = {
      input = {
        insert_only = false,
        border = "rounded",
        relative = "editor",
        title_pos = "left",
        min_width = { 0.4, 72 },
        mappings = { n = { ["q"] = "Close" } },
      },
      select = {
        backend = { "builtin" },
        trim_prompt = true,
        builtin = {
          mappings = { n = { ["q"] = "Close" } },
          show_numbers = false,
          relative = "editor",
          border = "rounded",
        },
        telescope = {
          layout_config = {
            horizontal = { width = 0.7, height = 0.55 },
          },
        },
        get_config = function(opts)
          -- code actions: show at cursor
          if opts.kind == "codeaction" then
            return { builtin = { relative = "cursor" } }
          end

          -- complex selectors: use telescope
          local useTelescope = {
            "mason.ui.language-filter",
          }
          if vim.tbl_contains(useTelescope, opts.kind) then
            return { backend = "telescope" }
          end
        end,
      },
    },
  },
  {
    "nvim-focus/focus.nvim",
    cmd = { "FocusSplitNicely", "FocusSplitLeft", "FocusSplitRight", "FocusSplitDown" },
    version = false,
    config = function()
      local focus = require("focus")
      focus.setup({
        enable = true, -- Enable module
        commands = true, -- Create Focus commands
        autoresize = {
          enable = true, -- Enable or disable auto-resizing of splits
          width = 0, -- Force width for the focused window
          height = 0, -- Force height for the focused window
          minwidth = 0, -- Force minimum width for the unfocused window
          minheight = 0, -- Force minimum height for the unfocused window
          height_quickfix = 10, -- Set the height of quickfix panel
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
          cursorcolumn = false, -- Display cursorcolumn in the focussed window only
          colorcolumn = {
            enable = false, -- Display colorcolumn in the foccused window only
            list = "+1", -- Set the comma-saperated list for the colorcolumn
          },
          signcolumn = true, -- Display signcolumn in the focussed window only
          winhighlight = false, -- Auto highlighting for focussed/unfocussed windows
        },
      })
    end,
  },
  {
    --- [TODO:fix]
    "folke/edgy.nvim",
    event = "KindaLazy",
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
            size = { height = 0.25 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          {
            ft = "noice",
            size = { height = 0.4 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          -- {
          --   ft = "lazyterm",
          --   title = "LazyTerm",
          --   size = { height = 0.4 },
          --   filter = function(buf)
          --     return not vim.b[buf].lazyterm_cmd
          --   end,
          -- },
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
        -- left = {
        --   {
        --     title = "Neo-Tree",
        --     ft = "neo-tree",
        --     filter = function(buf)
        --       return vim.b[buf].neo_tree_source == "filesystem"
        --     end,
        --     pinned = true,
        --     open = function()
        --       vim.api.nvim_input("<esc><space>e")
        --     end,
        --     size = { height = 0.5 },
        --   },
        --   { title = "Neotest Summary", ft = "neotest-summary" },
        --   {
        --     title = "Neo-Tree Git",
        --     ft = "neo-tree",
        --     filter = function(buf)
        --       return vim.b[buf].neo_tree_source == "git_status"
        --     end,
        --     pinned = true,
        --     open = "Neotree position=right git_status",
        --   },
        --   {
        --     title = "Neo-Tree Buffers",
        --     ft = "neo-tree",
        --     filter = function(buf)
        --       return vim.b[buf].neo_tree_source == "buffers"
        --     end,
        --     pinned = true,
        --     open = "Neotree position=top buffers",
        --   },
        --   "neo-tree",
        --},
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
      }
      return opts
    end,
  },
}
