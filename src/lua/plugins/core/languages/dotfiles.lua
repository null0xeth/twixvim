return {
  {
    "luckasRanarison/tree-sitter-hypr",
    event = "BufRead */hypr/*.conf",
    config = function()
      -- Fix ft detection for hyprland
      vim.filetype.add({
        pattern = { [".*/hypr/.*%.conf"] = "hypr" },
      })
      require("nvim-treesitter.parsers").get_parser_configs().hypr = {
        install_info = {
          url = "https://github.com/luckasRanarison/tree-sitter-hypr",
          files = { "src/parser.c" },
          branch = "master",
        },
        filetype = "hypr",
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local function add(lang)
        if type(opts.ensure_installed) == "table" then
          table.insert(opts.ensure_installed, lang)
        end
      end

      vim.filetype.add({
        extension = { rasi = "rasi" },
        pattern = {
          [".*/waybar/config"] = "jsonc",
          [".*/mako/config"] = "dosini",
          [".*/kitty/*.conf"] = "bash",
        },
      })

      add("git_config")
      add("rasi")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        dockerls = {
          cmd = {
            "docker-langserver",
            "--stdio",
          },
          settings = {},
        },
      },
      setup = {
        dockerls = function(_, opts)
          local lspcontroller = require("framework.controller.lspController"):new()
          lspcontroller:setup_lsp_servers(_, opts)
        end,
      },
    },
  },
}
