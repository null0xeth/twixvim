local instance_cache = {}
local module_cache = {}
local opt = vim.opt

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
local StatusLineController = uicontroller:new("framework.view.statuslineview", "statuslineview") ---@class StatusLineController: UiController
StatusLineController.__index = StatusLineController

---@public
---@param self StatusLineController
---@return StatusLineController obj
function StatusLineController:new()
  local obj = setmetatable({}, self)
  self.__index = self
  return obj
end

local function generate_autocmd()
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local is_neotree = vim.fn.bufname("%") == "neo-tree"
end

function StatusLineController:setup()
  local opts = self.view:render()
  local lualine = get_module("lualine", "lualine")
  vim.opt.laststatus = vim.g.lualine_laststatus

  lualine.setup(opts)
  --generate_autocmd()
end

return StatusLineController
