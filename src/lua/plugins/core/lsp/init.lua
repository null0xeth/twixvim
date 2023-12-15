-- local function fqn(fname)
--   fname = vim.fn.fnamemodify(fname, ":p")
--   return vim.loop.fs_realpath(fname) or fname
-- end

-- local function exists(fname)
--   local stat = vim.loop.fs_stat(fname)
--   return (stat and stat.type) or false
-- end

-- local function has_file(root_dir, file)
--   root_dir = fqn(root_dir)
--   file = fqn(file)
--   return exists(file) and file:find(root_dir, 1, true) == 1
-- end

local spec = {
  {
    "folke/neodev.nvim",
    --event = "KindaLazy",
    config = function()
      require("neodev").setup({
        library = {
          enabled = true,
          runtime = true,
          plugins = {
            "nvim-cmp",
            "plenary.nvim",
            "neotest",
            "nvim-dap",
            "nvim-notify",
            "nui.nvim",
            "nvim-lspconfig",
            "nvim-dap-ui",
          },
          types = true,
        },
        lspconfig = true,
        pathStrict = true,
      })
    end,
  },
  -- {
  --   "antosha417/nvim-lsp-file-operations",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-neo-tree/neo-tree.nvim",
  --   },
  --   config = function()
  --     require("lsp-file-operations").setup()
  --   end,
  -- },
  {
    "neovim/nvim-lspconfig",
    event = "KindaLazy",
    dependencies = {
      --{ "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
      { "folke/neodev.nvim" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "smjonas/inc-rename.nvim" },
    },
    opts = {
      servers = {},
      setup = {},
      format = {},
    },
    config = function(plugin, opts)
      local lspcontroller = require("framework.controller.lspcontroller"):new()
      lspcontroller:setup_lsp_servers(plugin, opts)
    end,
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason" },
    opts = {
      ensure_installed = {},
    },
    config = function(_, opts)
      local lspcontroller = require("framework.controller.lspcontroller"):new()
      lspcontroller:setup_mason(opts)
    end,
  },
  {
    "stevearc/conform.nvim",
    event = "KindaLazy",
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        bash = { "shfmt" },
        ["*"] = { "trim_whitespace" },
      },
      format_on_save = {
        lsp_fallback = true,
        async = true,
        quiet = true,
      },
    },
  },
  {
    "mhartington/formatter.nvim",
    enabled = false,
    event = "BufReadPre",
    config = function()
      local cachecontroller = require("framework.controller.cachecontroller"):new()
      local formatters = cachecontroller:query("formatters")
      require("formatter").setup(formatters)
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      linters_by_ft = {
        html = { "tidy" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft
    end,
  },
}
return spec
