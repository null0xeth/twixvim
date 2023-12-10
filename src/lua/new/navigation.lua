local spec = {
  {
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
  {
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
  {
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
}

return spec
