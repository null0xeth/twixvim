local spec = {
  {
    -- code outline
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
  {
    "echasnovski/mini.map",
    opts = true,
    keys = {
      --stylua: ignore
      { "<leader>vm", function() require("mini.map").toggle {} end, desc = "Toggle Minimap" },
    },
    config = function(_, opts)
      require("mini.map").setup(opts)
    end,
  },
  {
    "simrat39/symbols-outline.nvim",
    keys = { { "<leader>vso", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    opts = true,
  },
}

return spec
