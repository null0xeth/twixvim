return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { [[<C-\>]] },
      { "<leader>vt", "<Cmd>2ToggleTerm<Cr>", desc = "Terminal" },
    },
    opts = {
      size = 15,
      hide_numbers = true,
      open_mapping = [[<C-\>]],
      shade_filetypes = {},
      shade_terminals = false,
      shading_factor = 0.3,
      start_in_insert = true,
      persist_size = true,
      direction = "horizontal",
      winbar = {
        enabled = false,
        name_formatter = function(term)
          return term.name
        end,
      },
    },
  },
  { --done
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
