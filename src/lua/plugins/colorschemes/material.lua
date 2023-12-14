return {
  {
    "marko-cerovac/material.nvim",
    name = "material",
    priority = 1000,
    lazy = false,
    opts = {
      contrast = {
        sidebars = false,
        floating_windows = false,
        line_numbers = false,
        sign_column = false,
        cursor_line = false,
        non_current_windows = false,
        popup_menu = false,
      },

      italics = {
        comments = false,
        keywords = false,
        functions = false,
        strings = false,
        variables = false,
      },

      contrast_filetypes = {
        "terminal",
        "lazy",
        "qf",
      },

      high_visibility = {
        lighter = false,
        darker = false,
      },

      disable = {
        colored_cursor = false,
        borders = false,
        background = true,
        term_colors = false,
        eob_lines = false,
      },

      lualine_style = "default",

      async_loading = true,

      custom_highlights = {},
    },
    config = function(_, opts)
      require("material").setup(opts)
      vim.g.material_style = "darker"
      vim.cmd.colorscheme "material"
    end,
  },
}
