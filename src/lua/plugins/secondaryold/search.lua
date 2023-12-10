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

return {
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
  {
    "cshuaimin/ssr.nvim",
    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
      keymaps = {
        close = "q",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<leader><cr>",
      },
    },
    keys = {
      {
        "<leader>srr",
        function()
          require("ssr").open()
        end,
        mode = { "n", "x" },
        desc = "Search and Replace (SSR)",
      },
    },
  },
  { -- refactoring utilities
    "ThePrimeagen/refactoring.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = true,
    keys = {
			-- stylua: ignore start
			{"<leader>ri", function() require("refactoring").refactor("Inline Variable") end,  desc = "󱗘 Inline Var (Refactoring)" },
			{"<leader>re", function() require("refactoring").refactor("Extract Variable") end, desc = "󱗘 Extract Var (Refactoring)" },
			{"<leader>ru", function() require("refactoring").refactor("Extract Function") end, desc = "󱗘 Extract Func (Refactoring)" },
      -- stylua: ignore end
    },
  },
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>sst", function() require("spectre").toggle() end, desc = "Toggle (Spectre)" },
      { '<leader>ssw', function() require("spectre").open_visual({select_word=true}) end, desc = "Search Current Word (Spectre)" },
      { '<leader>ssv', function() require("spectre").open_visual() end, desc = "Open Visual Panel (Spectre)" },
      { '<leader>ssv', function() require("spectre").open_file_search({select_word=true}) end, desc = "Search in File (Spectre)" },
    },
  },
}
