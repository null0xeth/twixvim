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

---@class UiController
local UiController = {}
UiController.__index = UiController
UiController.view = nil

---@public
---@param self UiController
---@param view_path? string
---@param view_name? string
---@return UiController
function UiController:new(view_path, view_name)
  local obj = {}
  setmetatable(obj, UiController)
  if view_path and view_name then
    obj.view = get_obj(view_path, view_name, obj)
  end
  return obj
end

return UiController
