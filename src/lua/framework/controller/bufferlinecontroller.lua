local instance_cache = {}
local module_cache = {}

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

local uicontroller = require("framework.controller.uicontroller") ---@type UiController
local BufferLineController = uicontroller:new() ---@class BufferLineController: UiController, CacheController
BufferLineController.__index = BufferLineController
setmetatable(BufferLineController, { __index = get_module("framework.controller.cachecontroller", "cachecontroller") })

---@public
---@param self BufferLineController
---@return BufferLineController obj
function BufferLineController:new()
  local obj = get_obj("framework.controller.cachecontroller", "cachecontroller")
  setmetatable(obj, { __index = BufferLineController })
  return obj
end

function BufferLineController:is_catppuccin()
  local cache = self:query("colorschemes")
  local result = cache[1]
  if result == "catppuccin" then
    local mod = get_module("catppuccin.groups.integrations.bufferline", "catppuccin-bufferline")
    return mod.get()
  else
    return {}
  end
end

function BufferLineController:generate_template()
  local catppuccin = self:is_catppuccin()
  local bufferline = get_module("bufferline", "bufferline")
  local template = {
    highlights = catppuccin,
    options = {
      mode = "buffers", -- set to "tabs" to only show tabpages instead
      style_preset = bufferline.style_preset.default, -- or bufferline.style_preset.minimal,
      themable = true, -- allows highlight groups to be overriden i.e. sets highlights as default
      numbers = "ordinal", --function({ ordinal, id, lower, raise }): string,
      close_command = "bdelete! %d", -- can be a string | function, | false see "Mouse actions"
      right_mouse_command = "bdelete! %d", -- can be a string | function | false, see "Mouse actions"
      left_mouse_command = "buffer %d", -- can be a string | function, | false see "Mouse actions"
      middle_mouse_command = nil, -- can be a string | function, | false see "Mouse actions"
      indicator = {
        icon = "▎", -- this should be omitted if indicator style is not 'icon'
        style = "icon",
      },
      buffer_close_icon = "󰅖",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      max_name_length = 18,
      max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
      truncate_names = true, -- whether or not tab names should be truncated
      tab_size = 18,
      -- diagnostics = "nvim_lsp",
      -- diagnostics_update_in_insert = false,
      -- diagnostics_indicator = function(count, level)
      --   local icon = level:match("error") and " " or ""
      --   return " " .. icon .. count
      -- end,
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "left",
          separator = true,
        },
      },
      color_icons = true, -- whether or not to add the filetype icon highlights
      show_buffer_icons = true, -- disable filetype icons for buffers
      show_buffer_close_icons = true,
      show_close_icon = false,
      show_tab_indicators = true,
      show_duplicate_prefix = false, -- whether to show duplicate buffer prefix
      persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
      move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
      separator_style = "thick", --slant
      enforce_regular_tabs = true,
      always_show_bufferline = false,
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
      sort_by = "id",
    },
  }
  return template
end

function BufferLineController:setup()
  local bufferline = get_module("bufferline", "bufferline")
  local template = self:generate_template()
  bufferline.setup(template)
end

return BufferLineController
