local log = require("util.logger"):new()
log:start_timer("main_dir_secondary_plugins")

local spec = {
  require("plugins.secondary.diagnostics"),
  require("plugins.secondary.search"),
  require("plugins.secondary.git"),
  { "nacro90/numb.nvim", event = "BufReadPre", config = true },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "help",
      },
    },
    keys = {
      {
        "<leader>pr",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>pl",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>pq",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
}

log:stop_timer("main_dir_secondary_plugins")
return spec
