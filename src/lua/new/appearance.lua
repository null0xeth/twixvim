local spec = {
  { -- fixes scrolloff at end of file
    "Aasim-A/scrollEOF.nvim",
    event = "CursorMoved",
    opts = true,
  },
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = "KindaLazy",
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      local autocmdcontroller = require("framework.controller.autocmdcontroller"):new()
      autocmdcontroller:add_autocmd({
        event = "FileType",
        pattern = {
          "aerial",
          "help",
          "dashboard",
          "NvimTree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
        },
        command_or_callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "UIEnter",
    config = function()
      require("ibl").setup({
        debounce = 1000,
        indent = {
          char = "│", -- spaces
          tab_char = "│", -- tabs
        },
        whitespace = { highlight = { "Whitespace", "NonText" } },
        scope = { enabled = false },
        exclude = {
          filetypes = {
            "aerial",
            "markdown",
            "vimwiki",
            "help",
            "dashboard",
            "NvimTree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lspinfo",
            "checkhealth",
            "TelescopePrompt",
            "TelescopeResults",
          },
        },
      })
    end,
  },
  {
    "andymass/vim-matchup",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    event = "KindaLazy",
    keys = {
      { "m", "<Plug>(matchup-%)", desc = "Goto Matching Bracket" },
    },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  {
    "RRethy/vim-illuminate",
    event = "KindaLazy",
    opts = {
      providers = {
        "lsp",
        "treesitter",
        "regex",
      },
      delay = 100,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
      filetypes_denylist = {
        "NvimTree",
        "aerial",
        "undotree",
        "spectre_panel",
        "help",
        "lazy",
        "mason",
        "notify",
        "lspinfo",
        "TelescopePrompt",
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },
  {
    "m-demare/hlargs.nvim",
    event = "KindaLazy",
    opts = {
      color = "#ef9062",
      use_colorpalette = false,
      disable = function(_, bufnr)
        if vim.b.semantic_tokens then
          return true
        end
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, c in pairs(clients) do
          local caps = c.server_capabilities
          if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
            vim.b.semantic_tokens = true
            return vim.b.semantic_tokens
          end
        end
      end,
    },
  },
}

return spec
