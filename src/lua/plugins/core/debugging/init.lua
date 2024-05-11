local spec = {
  {
    "mfussenegger/nvim-dap",
    event = "KindaLazy",
    dependencies = {
      { "rcarriga/nvim-dap-ui" },
      { "nvim-neotest/nvim-nio" },
      {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          require("nvim-dap-virtual-text").setup({
            all_frames = true,
            --commented = true,
          })
        end,
      },
      {
        "rcarriga/cmp-dap",
        dependencies = { "hrsh7th/nvim-cmp" },
        config = function()
          require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
            sources = {
              { name = "dap" },
            },
          })
        end,
      },
    },
    config = function()
      local dapcontroller = require("framework.controller.dapcontroller"):new()
      dapcontroller:setup_nvim_dap()
    end,
  },
}

return spec
