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
    "tomiis4/Hypersonic.nvim",
    event = "CmdlineEnter",
    cmd = "Hypersonic",
    config = function()
      require("hypersonic").setup({
        -- config
      })
    end,
  },
  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("nvim-navic").setup({
        highlight = true,
        --separator = " ",
        --depth_limit = 5,
        --lazy_update_context = true,
        icons = { Object = "󰆧 " },
        separator = "  ",
        depth_limit = 0,
        depth_limit_indicator = "…",
        safe_output = true,
      })
    end,
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
      filetype_exclude = {
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
        "edgy",
      },
    },
  },
}

return spec
