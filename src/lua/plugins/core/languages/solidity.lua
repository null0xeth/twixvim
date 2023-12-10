return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "solhint",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = {
        solidity = { "solhint" },
      }
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- solc = {},
        -- solang = {},
        solidity_ls_nomicfoundation = {},
      },
    },
  },
}
