local loop = vim.loop
local schedule_wrap = vim.schedule_wrap
local api = vim.api
local bo = vim.bo
local fn = vim.fn
local module_cache = {}
local instance_cache = {}

---@package
---@param name string
---@param cacheKey string
---@return table
local function get_module(name, cacheKey)
  if module_cache[cacheKey] then
    return module_cache[cacheKey]
  end
  module_cache[cacheKey] = require(name)
  return module_cache[cacheKey]
end

---@package
---@param name string
---@param cacheKey string
---@return table
local function get_obj(name, cacheKey, inheritance)
  local uninitialized_obj = get_module(name, cacheKey)
  if instance_cache[cacheKey] then
    return instance_cache[cacheKey]
  end

  if inheritance then
    instance_cache[cacheKey] = uninitialized_obj:new(inheritance)
    return instance_cache[cacheKey]
  end

  instance_cache[cacheKey] = uninitialized_obj:new()
  return instance_cache[cacheKey]
end

---@class StatusLineView
local StatusLineView = {}
StatusLineView.__index = StatusLineView

---@public
---@param self StatusLineView
---@param controller StatusLineController
---@return StatusLineView
function StatusLineView:new(controller)
  local obj = { controller = controller }
  setmetatable(obj, { __index = StatusLineView })
  return obj ---@type StatusLineView
end

local function schedule_statusline_render()
  local timer = nil
  if not timer then
    timer = loop.new_timer()
  else
    timer:stop()
  end

  timer:start(
    0,
    1000,
    schedule_wrap(function()
      api.nvim_command("redrawstatus")
    end)
  )
end

local function is_package_loaded(pname)
  return package.loaded[pname]
end

local function get_gitsigns()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

local bottomSep = { left = "", right = "" } -- nerdfont-powerline icons have prefix 'ple-'
local bottomComp = { left = "", right = "" }
local topSep = { left = "", right = "" }
local topComp = { left = "", right = "" }

local separators = {
  left = { "", " " }, -- separator for the left side of the statusline
  right = { " ", "" }, -- separator for the right side of the statusline
  tab = { "", "" },
}

local function create_statusline_template()
  local cachecontroller = get_obj("framework.controller.cachecontroller", "cachecontroller")
  local icons = cachecontroller:query("icons")
  local filename_symbols = {
    modified = " ",
    readonly = " ",
    unnamed = "unnamed",
  }
  local opts = {
    options = {
      icons_enabled = true,
      theme = "auto",
      globalstatus = true, -- false
      --component_separators = { left = "", right = "" },
      --component_separators = { left = "", right = "" },
      component_separators = topComp,
      section_separators = topSep,
      disabled_filetypes = {
        statusline = {
          "DressingInput",
          "DressingSelect",
          "lspinfo",
          "TelescopePrompt",
          "checkhealth",
          "noice",
          "lazy",
          "mason",
          "qf",
          "dashboard",
          "fugitive",
          "edgy",
          "",
        },
        winbar = {
          "edgy",
        },
      },

      -- shows up regardless whether in ignore
      ignore_focus = {
        "toggleterm",
        "help",
        "aerial",
        "dap-repl",
        "dapui_console",
        "dapui_watches",
        "dapui_stacks",
        "dapui_breakpoints",
        "dapui_scopes",
        "dapui_hover",
        --"neo-tree",
      },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        --"branch",
        {
          "b:gitsigns_head",
          icon = { "" },
          color = { gui = "bold" },
        },
        {
          "diff",
          symbols = {
            added = icons.git.add .. " ",
            modified = icons.git.change .. " ",
            removed = icons.git.delete .. " ",
          },
          padding = { left = 2, right = 1 },
          source = get_gitsigns(),
        },
      },
      lualine_c = {
        {
          "filename",
          file_status = true,
          newfile_status = false,
          path = 0,
          symbols = filename_symbols,
        },
        -- {
        --   function()
        --     return require("nvim-navic").get_location()
        --   end,
        --   cond = function()
        --     return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
        --   end,
        -- } get option value
      },
      lualine_x = {
        { -- Lsp server name .
          function()
            local msg = "No Active Lsp"
            --local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
            local buf_ft = vim.api.nvim_get_option_value("filetype", 0)
            local clients = vim.lsp.get_clients()
            if next(clients) == nil then
              return msg
            end
            for _, client in ipairs(clients) do
              local filetypes = client.config.filetypes
              if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
              end
            end
            return msg
          end,
          icon = { " " },
          color = { gui = "bold" },
          --color = { fg = "#ffffff", gui = "bold" },
        },
      },
      --render_lualine_x(),
      -- lualine_x = {
      --   -- stylua: ignore
      --   {
      --     function() return require("noice").api.status.command.get() end,
      --     cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,

      --   },
      --   -- stylua: ignore
      --   {
      --     function() return require("noice").api.status.mode.get() end,
      --     cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
      --   },
      --   -- stylua: ignore
      --   {
      --     function() return "  " .. require("dap").status() end,
      --     cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
      --   },
      --   {
      --     require("lazy.status").updates,
      --     cond = require("lazy.status").has_updates,
      --   },
      --},
      lualine_y = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          sections = { "error", "warn", "info", "hint" },
          symbols = { error = " ", warn = " ", info = " ", hint = " " },
        },
      },
      lualine_z = {
        -- function()
        --   return " " .. os.date("%R")
        -- end,
        {
          "datetime",
          style = "%H:%M",
          cond = function()
            return vim.o.columns > 110 and vim.o.lines > 25
          end,
          fmt = function(time)
            return os.time() % 2 == 0 and time or time:gsub(":", " ")
          end,
        },
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    -- winbar = {
    --   lualine_c = {
    --     {
    --       function()
    --         return navic.get_location()
    --       end,
    --       cond = function()
    --         return navic.is_available()
    --       end,
    --     },
    --   },
    -- },
    extensions = {},
  }
  return opts
end

---@protected
---@param self StatusLineView
function StatusLineView:render()
  schedule_statusline_render()
  return create_statusline_template()
end

return StatusLineView
