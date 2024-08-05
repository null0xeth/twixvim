local b = vim.b

local spec = {
  { -- fixes scrolloff at end of file
    "Aasim-A/scrollEOF.nvim",
    event = "CursorMoved",
    opts = true,
  },
  { -- fixes scrolloff at end of file
    "LudoPinelli/comment-box.nvim",
    event = "KindaLazy",
    config = function()
      require("comment-box").setup()
    end,
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
          "Float",
          "aerial",
          "netrw",
          "vimwiki",
          "help",
          "markdown",
          "dashboard",
          "NvimTree",
          "edgy",
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
          "dapui_watches",
          "dapui_breakpoints",
          "dapui_scopes",
          "dapui_console",
          "dapui_stacks",
          "dap-repl",
          "neo-tree",
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
    enabled = false,
    event = "KindaLazy",
    config = function()
      require("ibl").setup({
        indent = {
          char = "",
        },
        scope = { enabled = false },
        exclude = {
          buftypes = { "terminal", "nofile", "telescope" },
          filetypes = {
            "",
            "Float",
            "help",
            "markdown",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",
            "dapui_breakpoints",
            "dapui_hover",
            "dap-repl",
            "edgy",
            "term",
            "fugitive",
            "fugitiveblame",
            "neo-tree",
            "neotest-summary",
            "Outline",
            "lsp-installer",
            "mason",
            "aerial",
            "netrw",
            "vimwiki",
            "dashboard",
            "Trouble",
            "trouble",
            "lazy",
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
      -- vim.g.matchup_enabled = true
      -- vim.g.matchup_surround_enabled = 0
      -- vim.g.matchup_transmute_enabled = 0
      -- vim.g.matchup_matchparen_deferred = 1
      -- vim.g.matchup_matchparen_hi_surround_always = 1
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
        "",
        "help",
        "markdown",
        "dapui_scopes",
        "dapui_stacks",
        "dapui_watches",
        "dapui_breakpoints",
        "dapui_hover",
        "dap-repl",
        "edgy",
        "term",
        "fugitive",
        "fugitiveblame",
        "neo-tree",
        "neotest-summary",
        "Outline",
        "lsp-installer",
        "mason",
        "aerial",
        "netrw",
        "vimwiki",
        "dashboard",
        "Trouble",
        "trouble",
        "lazy",
        "notify",
        "toggleterm",
        "lspinfo",
        "checkhealth",
        "TelescopePrompt",
        "TelescopeResults",
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },
  {
    "echasnovski/mini.icons",
    event = "KindaLazy",
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "m-demare/hlargs.nvim",
    event = "KindaLazy",
    opts = {
      color = "#ef9062",
      use_colorpalette = false,
      disable = function(_, bufnr)
        if b.semantic_tokens then
          return true
        end
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        for _, c in pairs(clients) do
          local caps = c.server_capabilities
          if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
            b.semantic_tokens = true
            return b.semantic_tokens
          end
        end
      end,
    },
  },
}

return spec
