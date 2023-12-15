local spec = {
  {
    "vim-test/vim-test",
    -- stylua: ignore
    keys = {
      { "<leader>tvc", "<cmd>w|TestClass<cr>", desc = "Class" },
      { "<leader>tvf", "<cmd>w|TestFile<cr>", desc = "File" },
      { "<leader>tvl", "<cmd>w|TestLast<cr>", desc = "Last" },
      { "<leader>tvn", "<cmd>w|TestNearest<cr>", desc = "Nearest" },
      { "<leader>tvs", "<cmd>w|TestSuite<cr>", desc = "Suite" },
      { "<leader>tvv", "<cmd>w|TestVisit<cr>", desc = "Visit" },
    },
    config = function()
      vim.g["test#strategy"] = "neovim"
      vim.g["test#neovim#term_position"] = "belowright"
      vim.g["test#neovim#preserve_screen"] = 1

      vim.g["test#python#runner"] = "pyunit" -- pytest
    end,
  },
  {
    "nvim-neotest/neotest",
    -- stylua: ignore
    keys = {
      { "<leader>tnF", "<cmd>w|lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", desc = "Debug File" },
      { "<leader>tnL", "<cmd>w|lua require('neotest').run.run_last({strategy = 'dap'})<cr>", desc = "Debug Last" },
      { "<leader>tna", "<cmd>w|lua require('neotest').run.attach()<cr>", desc = "Attach" },
      { "<leader>tnf", "<cmd>w|lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "File" },
      { "<leader>tnl", "<cmd>w|lua require('neotest').run.run_last()<cr>", desc = "Last" },
      { "<leader>tnn", "<cmd>w|lua require('neotest').run.run()<cr>", desc = "Nearest" },
      { "<leader>tnN", "<cmd>w|lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "Debug Nearest" },
      { "<leader>tno", "<cmd>w|lua require('neotest').output.open({ enter = true })<cr>", desc = "Output" },
      { "<leader>tns", "<cmd>w|lua require('neotest').run.stop()<cr>", desc = "Stop" },
      { "<leader>tnS", "<cmd>w|lua require('neotest').summary.toggle()<cr>", desc = "Summary" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-vim-test",
      "vim-test/vim-test",
      "nvim-neotest/neotest-plenary",
      "stevearc/overseer.nvim",
    },
    opts = function()
      return {
        adapters = {
          require("neotest-vim-test")({
            ignore_file_types = { "python", "vim", "lua" },
          }),
          require("neotest-plenary"),
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            if require("utils").has("trouble.nvim") then
              vim.cmd("Trouble quickfix")
            else
              vim.cmd("copen")
            end
          end,
        },
        -- overseer.nvim
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        overseer = {
          enabled = true,
          force_default = true,
        },
      }
    end,
    config = function(_, opts)
      -- local neotest_ns = vim.api.nvim_create_namespace("neotest")
      -- vim.diagnostic.config({
      --   virtual_text = {
      --     format = function(diagnostic)
      --       local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
      --       return message
      --     end,
      --   },
      -- }, neotest_ns)
      require("neotest").setup(opts)
    end,
  },
  {
    "stevearc/overseer.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>toR", "<cmd>OverseerRunCmd<cr>", desc = "Run Command" },
      { "<leader>toa", "<cmd>OverseerTaskAction<cr>", desc = "Task Action" },
      { "<leader>tob", "<cmd>OverseerBuild<cr>", desc = "Build" },
      { "<leader>toc", "<cmd>OverseerClose<cr>", desc = "Close" },
      { "<leader>tod", "<cmd>OverseerDeleteBundle<cr>", desc = "Delete Bundle" },
      { "<leader>tol", "<cmd>OverseerLoadBundle<cr>", desc = "Load Bundle" },
      { "<leader>too", "<cmd>OverseerOpen<cr>", desc = "Open" },
      { "<leader>toq", "<cmd>OverseerQuickAction<cr>", desc = "Quick Action" },
      { "<leader>tor", "<cmd>OverseerRun<cr>", desc = "Run" },
      { "<leader>tos", "<cmd>OverseerSaveBundle<cr>", desc = "Save Bundle" },
      { "<leader>tot", "<cmd>OverseerToggle<cr>", desc = "Toggle" },
    },
    config = true,
  },
}

return spec
