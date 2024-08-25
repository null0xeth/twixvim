local spec = {
  {
    "luukvbaal/statuscol.nvim",
    enabled = true,
    branch = "0.10",
    event = "VeryLazy",
    config = function()
      -- config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        setopt = true, -- Whether to set the 'statuscolumn' option, may be set to false for those who
        relculright = true, -- whether to right-align the cursor line number with 'relativenumber' set

        --   require("statuscol").setup({
        -- configuration goes here, for example:
        bt_ignore = {
          "terminal",
          "nofile",
        },
        ft_ignore = {
          "neo-tree",
          "toggleterm",
          "help",
          "aerial",
          "markdown",
          "dashboard",
          "vim",
          "noice",
          "lazy",
        },
        segments = {
          {
            text = {
              builtin.foldfunc,
              " ",
            },
            click = "v:lua.ScFa",
          },
          {
            sign = {
              namespace = { ".*/diagnostic/signs" }, --"diagnostic" },
              maxwidth = 1,
              colwidth = 2,
              auto = true,
              foldclosed = true,
            },
            click = "v:lua.ScSa",
          },
          {
            sign = {
              name = { "Dap.*" },
              maxwidth = 1,
              colwidth = 2,
              auto = true,
            },
            click = "v:lua.ScLa",
          },
          {
            text = { builtin.lnumfunc, " " },
            click = "v:lua.ScLa",
            --[[             condition = { true, builtin.not_empty }, ]]
          },
          {
            sign = {
              namespace = { "gitsign*" },
              maxwidth = 1,
              colwidth = 1,
              auto = true,
            },
            click = "v:lua.ScSa",
          },
          -- Segment: Add padding
          {
            text = { " " },
            hl = "Normal",
            condition = { true, builtin.not_empty },
          },
        },
        --})
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = {
      "luukvbaal/statuscol.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local signs = require("template.icons_tpl").git.signs
      return {
        sign_priority = 100,
        _extmark_signs = true,
        signs = {
          add = { text = signs.add },
          change = { text = signs.change },
          delete = { text = signs.delete },
          topdelete = { text = signs.topdelete },
          changedelete = { text = signs.changedelete },
          untracked = { text = signs.untracked },
        },
        preview_config = {
          border = "rounded",
          style = "minimal",
          relative = "cursor",
          width = 88,
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          map("n", "]g", function()
            if vim.wo.diff then
              return "]g"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Next hunk" })

          map("n", "[g", function()
            if vim.wo.diff then
              return "[g"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous hunk" })

          -- Actions
          map("n", "<leader>gshs", gs.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>gshr", gs.reset_hunk, { desc = "Reset hunk" })
          map("v", "<leader>gshS", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Stage hunk" })
          map("v", "<leader>gshR", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Reset hunk" })
          map("n", "<leader>gsbs", gs.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>gshu", gs.undo_stage_hunk, { desc = "Unstage hunk" })
          map("n", "<leader>gsbr", gs.reset_buffer, { desc = "Reset buffer" })
          map("n", "<leader>gshp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>gslb", function()
            gs.blame_line({ full = true })
          end, { desc = "Blame line" })
          map("n", "<leader>gslu", gs.toggle_current_line_blame, { desc = "Toggle Git blame" })
          map("n", "<leader>gsdd", gs.diffthis, { desc = "Diff" })
          map("n", "<leader>gsdh", function()
            gs.diffthis("~")
          end, { desc = "Diff HEAD" })
          map("n", "<leader>gst", gs.toggle_deleted, { desc = "Toggle removed" })

          -- Text object
          map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
        end,
      }
    end,
  },

  {
    "akinsho/bufferline.nvim",
    event = "KindaLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local bufferlinecontroller = require("framework.controller.bufferlinecontroller"):new()
      bufferlinecontroller:setup()
    end,
  },
  {
    "utilyre/barbecue.nvim",
    enabled = false,
    event = "KindaLazy",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      attach_navic = false,
      show_dirname = false,
      show_basename = false,
      theme = "auto",
      exclude_filetypes = {
        "netrw",
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
        "dapui_watches",
        "dapui_breakpoints",
        "dapui_scopes",
        "dapui_console",
        "dapui_stacks",
        "dap-repl",
        "neo-tree",
        "",
        "nofile",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "KindaLazy",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      --{ "SmiteshP/nvim-navic" },
    },
    config = function()
      local statuslinecontroller = require("framework.controller.statuslinecontroller"):new()
      statuslinecontroller:setup()
    end,
  },
  { -- scrollbar with information
    "lewis6991/satellite.nvim",
    enabled = false,
    commit = "5d33376", -- TODO following versions require nvim 0.10
    event = "VeryLazy",
    opts = {
      winblend = 0, -- no transparency, hard to see in many themes otherwise
      handlers = {
        cursor = { enable = false },
        marks = { enable = false }, -- FIX mark-related error message
        quickfix = { enable = true },
      },
    },
  },
  {
    "glepnir/dashboard-nvim",
    event = "VimEnter",
    init = vim.schedule(function()
      local interface = require("framework.interfaces.engine_interface"):new()
      local is_dashboard = interface.is_plugin_loaded("dashboard-nvim")
      if not is_dashboard then
        require("lazy").load({ plugins = { "dashboard-nvim" } })
      end
    end),
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = vim.schedule(function()
      local dashboardcontroller = require("framework.controller.dashboardcontroller"):new()
      dashboardcontroller:initialize_dashboard()
    end),
  },
  {
    "rcarriga/nvim-notify",
    keys = {
      -- stylua: ignore
      { "<leader>ud", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Dismiss all (Nvim-Notify)", },
    },
    opts = {
      stages = "static",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
  },
}

return spec
