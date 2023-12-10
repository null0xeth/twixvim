local log = require("util.logger"):new()
log:start_timer("navigation_plugins")

local spec = {
  -- {
  --   "folke/which-key.nvim",
  --   optional = true,
  --   opts = function()
  --     local wk = require("which-key")
  --     wk.register({
  --       ["<leader>mr"] = { "+Reach" }, --done
  --       ["<leader>vs"] = { "+Symbols" }, --done
  --       ["<leader>mn"] = { "+Navigation" }, --done
  --     })
  --   end,
  -- },
  -- buffer remove
  { --done
    "echasnovski/mini.bufremove", --done
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      -- stylua: ignore
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },
  { --done
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      keymaps = {
        ["?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        [";v"] = "actions.select_vsplit",
        [";h"] = "actions.select_split",
        [";t"] = "actions.select_tab",
        [";p"] = "actions.preview",
        ["q"] = "actions.close",
        [";r"] = "actions.refresh",
        [".."] = "actions.parent",
        [";o"] = "actions.open_cwd",
        ["cd"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
    },
    keys = {
      { "<leader>mno", "<cmd>Oil<CR>", desc = "Browse parent directory (Oil)" },
      { "<leader>mnf", "<cmd>Oil --float <CR>", desc = "[FLOAT]: Browse parent directory (Oil)" },
    },
  },
  { --done
    "axkirillov/hbac.nvim",
    event = "KindaLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("hbac").setup({
        autoclose = true,
        threshold = 10,
        close_command = function(bufnr)
          vim.api.nvim_buf_delete(bufnr, {})
        end,
      })
    end,
  },
  { --done
    "simrat39/symbols-outline.nvim",
    keys = { { "<leader>vso", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    cmd = "SymbolsOutline",
    opts = {},
  },
  { --done
    "echasnovski/mini.map",
    opts = {},
    keys = {
      --stylua: ignore
      { "<leader>vm", function() require("mini.map").toggle {} end, desc = "Toggle Minimap" },
    },
    config = function(_, opts)
      require("mini.map").setup(opts)
    end,
  },
  { --done
    "toppair/reach.nvim",
    cmd = { "ReachOpen" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>mrb", "<cmd>ReachOpen buffers<cr>", desc = "Open buffers" },
      { "<leader>mrt", "<cmd>ReachOpen tabpages<cr>", desc = "Open tabpages" },
      { "<leader>mrc", "<cmd>ReachOpen colorschemes<cr>", desc = "Open colorschemes" },
      { "<leader>mrm", "<cmd>ReachOpen marks<cr>", desc = "Open marks" },
    },
    config = function()
      require("reach").setup({
        notifications = true,
      })
    end,
  },
  { --done
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    cmd = { "NvimTreeToggle" },
    init = function()
      local keymapcontroller = require("framework.controller.keymapcontroller"):new()
      keymapcontroller:register_keymap("n", "<c-n>", "<cmd>NvimTreeToggle<CR>", { silent = true })
      keymapcontroller:register_keymap("n", "<Space>n", "<cmd>NvimTreeFocus<CR>", { silent = true })
    end,
    config = function()
      local navigationcontroller = require("framework.controller.navigationcontroller"):new()
      navigationcontroller:setup()
    end,
  },
  { --done
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
          "numToStr/Comment.nvim",
          "nvim-telescope/telescope.nvim",
        },
        opts = { lsp = { auto_attach = true } },
      },
    },
    --stylua: ignore
    keys = {
      { "<leader>vO", function() require("nvim-navbuddy").open() end, desc = "Code Outline (navbuddy)", },
    },
  },
  { --done
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
          -- telescopecontroller:load_extension("dap", {
          --   ["<leader>fD"] = { "+DAP" }, --done
          -- })
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
      -- local which_keys = { -- done
      --   ["<leader>ff"] = { "+Normal File Search" },
      --   ["<leader>fg"] = { "+General Commands" },
      --   ["<leader>fz"] = { "+Fuzzy File Search" },
      --   ["<leader>fd"] = { "+Diagnostics" },
      --   ["<leader>fl"] = { "+LSP Commands" },
      --   ["<leader>fG"] = { "+Git Commands" },
      -- }

      -- telescopecontroller:setup(which_keys)
    end,
  },
}

log:stop_timer("navigation_plugins")
return spec
