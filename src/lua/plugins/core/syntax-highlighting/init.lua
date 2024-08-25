local spec = {
  { -- virtual text context at the end of a scope
    "haringsrob/nvim_context_vt",
    event = "KindaLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",

    opts = {
      prefix = " 󱞷",
      highlight = "NonText",
      min_rows = 12,
      disable_ft = { "markdown", "yaml", "css" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = function()
      vim.schedule(function()
        vim.cmd(":TSUpdate")
      end)
    end,
    event = "KindaLazy",
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    dependencies = {
      { "JoosepAlviste/nvim-ts-context-commentstring" },
      { "LiadOz/nvim-dap-repl-highlights" },
      { "RRethy/nvim-treesitter-endwise" },
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      sync_install = true,
      auto_install = true,
      ensure_installed = {
        "bash",
        "comment",
        "dockerfile",
        "diff",
        "dap_repl",
        "html",
        "markdown",
        "markdown_inline",
        "printf",
        "org",
        "query",
        "regex",
        "latex",
        "vim",
        "vimdoc",
        "yaml",
      },
      highlight = {
        enable = true,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          enable = false,
        },
      },
      matchup = {
        enable = true,
        enable_quotes = false,
        disable_virtual_text = false,
        disable = { "rust" },
      },
      endwise = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
    },
    config = function(_, opts)
      local codingcontroller = require("framework.controller.codingcontroller"):new()
      codingcontroller:setup_treeshitter(opts)
    end,
  },
  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
    event = "KindaLazy",
    opts = {
      enable = false,
      mode = "cursor",
      max_lines = 3,
    },
    keys = {
      {
        "<leader>Sc",
        function()
          local tsc = require("treesitter-context")
          tsc.toggle()
        end,
        desc = "Toggle TS Context",
      },
    },
  },
  {
    "ckolkey/ts-node-action",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter" },
    -- stylua: ignore
    keys = {
      { "<leader>Sn", function() require("ts-node-action").node_action() end, desc = "TS Node Action" },
    },
  },
  {
    "Wansmer/treesj",
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    keys = {
      { "<leader>Sj", "<cmd>TSJToggle<cr>", desc = "Toggle TS Split/Join" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup({
        use_default_keymaps = false,
      })
    end,
  },
  {
    "rasulomaroff/reactive.nvim",
    enabled = false,
    event = "KindaLazy",
    config = function()
      local reactive = require("reactive")
      reactive.setup({
        load = { "catppuccin-mocha-cursor", "catppuccin-mocha-cursorline" },
        builtin = {
          cursorline = true,
          cursor = true,
          modemsg = true,
        },
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "KindaLazy",
    opts = {},
  },
}
return spec
