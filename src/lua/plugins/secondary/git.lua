return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    opts = {},
    keys = { { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Open DiffView" } },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
      { "<leader>gN", "<cmd>Neogit kind=floating<cr>", desc = "Git Status (Neogit)" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim", -- optional
    },
    config = function()
      require("neogit").setup()
    end,
  },

  -- {
  --   "lewis6991/gitsigns.nvim",
  --   dependencies = "nvim-lua/plenary.nvim",
  --   event = "KindaLazy",
  --   config = function()
  --     require("gitsigns").setup({
  --       word_diff = true,
  --       preview_config = {
  --         border = "rounded",
  --       },
  --       -- signs = {
  --       --   add = { text = "│" },
  --       --   change = { text = "│" },
  --       --   delete = { text = "_" },
  --       --   topdelete = { text = "‾" },
  --       --   changedelete = { text = "~" },
  --       --   untracked = { text = "┆" },
  --       -- },
  --       -- signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  --       -- numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  --       -- linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  --       -- word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  --       -- watch_gitdir = {
  --       --   follow_files = true,
  --       -- },
  --       -- attach_to_untracked = true,
  --       -- current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  --       -- current_line_blame_opts = {
  --       --   virt_text = true,
  --       --   virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
  --       --   delay = 1000,
  --       --   ignore_whitespace = false,
  --       --   virt_text_priority = 100,
  --       -- },
  --       -- current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  --       -- sign_priority = 6,
  --       -- update_debounce = 100,
  --       -- status_formatter = nil, -- Use default
  --       -- max_file_length = 40000, -- Disable if file is longer than this (in lines)
  --       -- preview_config = {
  --       --   -- Options passed to nvim_open_win
  --       --   border = "single",
  --       --   style = "minimal",
  --       --   relative = "cursor",
  --       --   row = 0,
  --       --   col = 1,
  --       -- },
  --       -- yadm = {
  --       --   enable = false,
  --       -- },
  --       on_attach = function(buffer)
  --         local wk = require("which-key")
  --         wk.register({
  --           ["<leader>gh"] = { "+Gitsigns" },
  --         })
  --         local gs = package.loaded.gitsigns
  --         local function map(mode, l, r, desc)
  --           vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
  --         end

  --       -- stylua: ignore start
  --       map("n", "]h", gs.next_hunk, "Next Hunk")
  --       map("n", "[h", gs.prev_hunk, "Prev Hunk")
  --       map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
  --       map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
  --       map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
  --       map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
  --       map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
  --       map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
  --       map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
  --       map("n", "<leader>ghd", gs.diffthis, "Diff This")
  --       map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
  --       map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  --       end,
  --     })
  --   end,
  -- opts = {
  --   sign_priority = 1,
  --   signs = {
  --     add = { text = "▎" },
  --     change = { text = "▎" },
  --     delete = { text = "" },
  --     topdelete = { text = "" },
  --     changedelete = { text = "▎" },
  --     untracked = { text = "▎" },
  --   },
  --   on_attach = function(buffer)
  --     local wk = require("which-key")
  --     wk.register({
  --       ["<leader>gh"] = { "+Gitsigns" },
  --     })
  --     local gs = package.loaded.gitsigns

  --     local function map(mode, l, r, desc)
  --       vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
  --     end

  --     -- stylua: ignore start
  --     map("n", "]h", gs.next_hunk, "Next Hunk")
  --     map("n", "[h", gs.prev_hunk, "Prev Hunk")
  --     map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
  --     map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
  --     map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
  --     map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
  --     map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
  --     map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
  --     map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
  --     map("n", "<leader>ghd", gs.diffthis, "Diff This")
  --     map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
  --     map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  --   end,
  -- },
  --},
}
