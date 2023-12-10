---https://www.reddit.com/r/neovim/comments/oxddk9/comment/h7maerh/
---@param name string name of highlight group
---@param key "fg"|"bg"
---@nodiscard
---@return string|nil the value, or nil if hlgroup or key is not available
local function getHighlightValue(name, key)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
  if not ok then
    return
  end
  local value = hl[key]
  if not value then
    return
  end
  return string.format("#%06x", value)
end

local spec = {
  { "tpope/vim-repeat", event = "KindaLazy" },
  {
    "tzachar/highlight-undo.nvim",
    keys = { "u", "U" },
    opts = {
      duration = 250,
      undo = {
        lhs = "u",
        map = "silent undo",
        opts = { desc = "󰕌 Undo" },
      },
      redo = {
        lhs = "U",
        map = "silent redo",
        opts = { desc = "󰑎 Redo" },
      },
    },
  },
  { -- when searching, search count is shown next to the cursor
    "kevinhwang91/nvim-hlslens",
    event = "KindaLazy",
    init = function()
      -- cannot use my utility, as the value of IncSearch needs to be retrieved dynamically
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          local reversed = getHighlightValue("IncSearch", "bg")
          vim.api.nvim_set_hl(0, "HLSearchReversed", { fg = reversed })
        end,
      })
    end,
    opts = {
      calm_down = true,
      nearest_only = true,
      override_lens = function(render, posList, nearest, idx, _)
        -- formats virtual text as a bubble
        local lnum, col = unpack(posList[idx])
        local text = ("%d/%d"):format(idx, #posList)
        local chunks = {
          { " ", "Ignore" }, -- = padding
          { "", "HLSearchReversed" },
          { text, "HlSearchLensNear" },
          { "", "HLSearchReversed" },
        }
        render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
      end,
    },
  },
  { -- automatically set correct indent for file
    "nmac427/guess-indent.nvim",
    event = "BufReadPre",
    opts = {
      -- due to code blocks and bullets often having spaces or tabs
      filetype_exclude = { "markdown", "aerial" },
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
    "sustech-data/wildfire.nvim",
    event = "KindaLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("wildfire").setup()
    end,
  },
}

return spec
