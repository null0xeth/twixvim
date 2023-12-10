local spec = {
  { -- :bnext & :bprevious get visual overview of buffers
    "ghillb/cybu.nvim",
    keys = {
      {
        "<BS>",
        function()
          require("cybu").cycle("prev")
        end,
        desc = "󰽙 Prev Buffer",
      },
      {
        "<Tab>",
        "<Plug>(CybuNext)",
        desc = "󰽙 Next Buffer",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
    opts = {
      display_time = 1000,
      position = {
        anchor = "bottomcenter",
        max_win_height = 12,
        vertical_offset = 3,
      },
      style = {
        border = "rounded",
        padding = 7,
        path = "tail",
        hide_buffer_id = true,
        highlights = { current_buffer = "CursorLine", adjacent_buffers = "Normal" },
      },
      behavior = {
        mode = {
          default = { switch = "immediate", view = "paging" },
        },
      },
    },
  },
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      -- stylua: ignore
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },
  { -- auto-close inactive buffers
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    opts = {
      retirementAgeMins = 10,
      ignoreUnsavedChangesBufs = false,
      notificationOnAutoClose = true,
      deleteBufferWhenFileDeleted = true,
    },
  },
  {
    "axkirillov/hbac.nvim",
    enabled = false,
    event = "KindaLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("hbac").setup({
        autoclose = true,
        threshold = 10,
        close_command = function(bufnr)
          vim.api.nvim_buf_delete(bufnr, {})
        end,
      })
    end,
  },
}

return spec
