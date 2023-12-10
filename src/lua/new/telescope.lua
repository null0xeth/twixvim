local spec = {
  {
    "nvim-telescope/telescope.nvim",
    version = false,
    cmd = { "Telescope" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          local telescopecontroller = require("framework.controller.telescopecontroller"):new()
          telescopecontroller:load_extension("fzf")
        end,
      },
      {
        "debugloop/telescope-undo.nvim",
        keys = { { "<leader>fU", "<cmd>Telescope undo<cr>", desc = "Telescope Undo" } },
        config = function()
          local telescopecontroller = require("framework.controller.telescopecontroller"):new()
          telescopecontroller:load_extension("undo")
        end,
      },
      {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = {
          "mfussenegger/nvim-dap",
          "nvim-treesitter/nvim-treesitter",
        },
        -- stylua: ignore
        keys = {
          { "<leader>fDc", "<cmd>Telescope dap commands<cr>",         desc = "Dap Commands" },
          { "<leader>fDC", "<cmd>Telescope dap configurations<cr>",   desc = "Dap Configurations" },
          { "<leader>fDb", "<cmd>Telescope dap list_breakpoints<cr>", desc = "Dap Breakpoints" },
          { "<leader>fDf", "<cmd>Telescope dap frames<cr>",           desc = "Dap Frames" },
        },
        config = function()
          local telescopecontroller = require("framework.controller.telescopecontroller"):new()
          telescopecontroller:load_extension("dap")
        end,
      },
      "LinArcX/telescope-command-palette.nvim",
      "AckslD/nvim-neoclip.lua",
    },
    --keys = "<space>",
    config = function()
      local telescopecontroller = require("framework.controller.telescopecontroller"):new()
      telescopecontroller:setup()
    end,
  },
}

return spec
