local spec = {
  {
    "akinsho/bufferline.nvim",
    event = "KindaLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local bufferlinecontroller = require("framework.controller.bufferlinecontroller"):new()
      bufferlinecontroller:setup()
    end,
  },
  {
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
  {
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
  {
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
  {
    "rcarriga/nvim-notify",
    keys = {
      -- stylua: ignore
      { "<leader>ud", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Dismiss all (Nvim-Notify)", },
    },
  },
}

return spec
