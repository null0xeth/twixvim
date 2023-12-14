local spec = {
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
return spec
