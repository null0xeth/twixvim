return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
      },
    },
  },
  -- {
  --   "stevearc/conform.nvim",
  --   opts = function(_, opts)
  --     opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, {
  --       cpp = { "clang_format" },
  --       c = { "clang_format" },
  --     })
  --   end,
  -- },
  -- {
  --   "mfussenegger/nvim-lint",
  --   opts = function(_, opts)
  --     opts.linters_by_ft["cpp"] = { "clang-tidy" }
  --     opts.linters_by_ft["c"] = { "clang-tidy" }
  --   end,
  -- },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "codelldb",
        "clang-format",
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.cppcheck,
        nls.builtins.diagnostics.cmake_lint,
        nls.builtins.formatting.clang_format,
        nls.builtins.formatting.cmake_format,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    --dependencies = { "p00f/clangd_extensions.nvim" },
    opts = {
      servers = {
        clangd = {
          server = {
            root_dir = function(...)
              -- using a root .clang-format or .clang-tidy file messes up projects, so remove them
              return require("lspconfig.util").root_pattern(
                "compile_commands.json",
                "compile_flags.txt",
                "configure.ac",
                ".git"
              )(...)
            end,
            capabilities = {
              offsetEncoding = { "utf-16" },
            },
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
          },
          extensions = {
            inlay_hints = {
              inline = false,
            },
            ast = {
              --These require codicons (https://github.com/microsoft/vscode-codicons)
              role_icons = {
                type = "",
                declaration = "",
                expression = "",
                specifier = "",
                statement = "",
                ["template argument"] = "",
              },
              kind_icons = {
                Compound = "",
                Recovery = "",
                TranslationUnit = "",
                PackExpansion = "",
                TemplateTypeParm = "",
                TemplateTemplateParm = "",
                TemplateParamObject = "",
              },
            },
          },
        },
      },
      setup = {
        clangd = function(_, opts)
          local lspcontroller = require("framework.controller.lspcontroller"):new()
          lspcontroller:setup_lsp_servers(_, opts)

          require("clangd_extensions").setup({
            server = opts.server,
            extensions = opts.extensions,
          })
          return true
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      setup = {
        codelldb = function()
          vim.schedule_wrap(function()
            local dapcontroller = require("framework.controller.dapcontroller"):new()
            dapcontroller:setup_rust_dap()
          end)()
        end,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "alfaix/neotest-gtest", opts = {} },
    },
    opts = {
      adapters = {
        function()
          require("neotest-gtest")
        end,
      },
    },
  },
}
