local default_opts = {
  -- CLI arguments to pass to manix, see `manix --help`
  -- for example: `{'--source', 'nixpkgs_doc', '--source', 'nixpkgs_comments'}`
  -- will restrict search to nixpkgs docs and comments.
  manix_args = {},
  -- Set to true to search for the word under the cursor
  cword = true,
}

local spec = {
  {
    "nvim-telescope/telescope.nvim",
    version = false,
    cmd = { "Telescope" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
      {
        "mrcjkb/telescope-manix",
        -- stylua: ignore
        keys = {
          { "<leader>fns", function() require('telescope-manix').search() end, desc = "Open Manix (Nix)" },
          { "<leader>fnc", function() require("telescope-manix").search(default_opts) end, desc = "Search cursorword" },
        },
        config = function()
          local telescopecontroller = require("framework.controller.telescopecontroller"):new()
          telescopecontroller:load_extension("manix")

          vim.keymap.set("n", "<leader>fnc", function()
            require("telescope-manix").search(default_opts)
          end, { desc = "Search cursorword" })
        end,
      },
      {
        "cappyzawa/telescope-terraform.nvim",
        config = function()
          local telescopecontroller = require("framework.controller.telescopecontroller"):new()
          telescopecontroller:load_extension("terraform")
        end,
      },
      {
        "ANGkeith/telescope-terraform-doc.nvim",
        config = function()
          local telescopecontroller = require("framework.controller.telescopecontroller"):new()
          telescopecontroller:load_extension("terraform_doc")
        end,
      },
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
    },
    --keys = "<space>",
    config = function()
      local telescopecontroller = require("framework.controller.telescopecontroller"):new()
      telescopecontroller:setup()
    end,
  },
}

return spec
