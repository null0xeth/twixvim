local log = require("util.logger"):new()
log:start_timer("appearance_plugins")

-- appearance
local long_opts = { silent = true, expr = true, mode = { "i", "n", "s" } }

local spec = {
  { -- scrollbar with information
    "lewis6991/satellite.nvim",
    commit = "5d33376", -- TODO following versions require nvim 0.10
    event = "VeryLazy",
    opts = {
      winblend = 0, -- no transparency, hard to see in many themes otherwise
      handlers = {
        cursor = { enable = false },
        marks = { enable = false }, -- FIX mark-related error message
        quickfix = { enable = true },
      },
    },
  },
  { -- done
    "utilyre/barbecue.nvim",
    enabled = true,
    event = "KindaLazy",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      attach_navic = false,
      show_dirname = false,
      show_basename = false,
      theme = "auto",
    },
  },
  { -- done
    "nvim-lualine/lualine.nvim",
    event = "KindaLazy",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "SmiteshP/nvim-navic" },
    },
    config = function()
      local statuslinecontroller = require("framework.controller.statuslinecontroller"):new()
      statuslinecontroller:setup()
    end,
  },
  { -- done
    "akinsho/bufferline.nvim",
    event = "KindaLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local bufferlinecontroller = require("framework.controller.bufferlinecontroller"):new()
      bufferlinecontroller:setup()
    end,
  },
  { --done
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
  { --done
    "rcarriga/nvim-notify",
    keys = {
      -- stylua: ignore
      { "<leader>ud", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Dismiss all (Nvim-Notify)", },
    },
  },
  { --done
    "glepnir/dashboard-nvim",
    event = "VimEnter",
    init = vim.schedule(function()
      local interface = require("framework.interfaces.engine_interface"):new()
      local is_dashboard = interface.is_plugin_loaded("dashboard-nvim")
      if not is_dashboard then
        require("lazy").load({ plugins = { "dashboard-nvim" } })
      end
    end),
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = vim.schedule(function()
      local dashboardcontroller = require("framework.controller.dashboardcontroller"):new()
      dashboardcontroller:initialize_dashboard()
    end),
  },
  { --done
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
  -- {
  --   "folke/which-key.nvim",
  --   opts = function()
  --     local wk = require("which-key")
  --     wk.register({ --done
  --       ["<leader>un"] = { "+Noice" },
  --     })
  --   end,
  -- },
  require("plugins.secondary.appearance.windows"),
}

log:stop_timer("appearance_plugins")
return spec
