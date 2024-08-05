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
    "neovim/nvim-lspconfig",
    event = "KindaLazy",
    dependencies = {
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
    event = "BufReadPre",
    enabled = true,
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 500,
        async = false,
        quiet = true,
      },
      format_after_save = {
        lsp_format = "fallback",
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
    "nvimtools/none-ls.nvim",
    event = "KindaLazy",
    dependencies = { "mason.nvim" },
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.actionlint, -- gh actions
        --nls.builtins.diagnostics.shellcheck,
        --nls.builtins.formatting.shfmt, -- add actionlint for gh
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    enabled = true,
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
