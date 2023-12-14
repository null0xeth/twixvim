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
local function get_obj(name, cacheKey)
  local uninitialized_obj = get_module(name, cacheKey)
  if instance_cache[cacheKey] then
    return instance_cache[cacheKey]
  end

  instance_cache[cacheKey] = uninitialized_obj:new()
  return instance_cache[cacheKey]
end

---@class CacheController: CacheModel
local CacheController = {}
CacheController.__index = CacheController
setmetatable(CacheController, { __index = get_module("framework.model.cachemodel", "cachemodel") })
CacheController.instance = nil
CacheController.memoize = {}

---@public
---@param self CacheController
---@return CacheController self.instance
function CacheController:new()
  if CacheController.instance then
    return CacheController.instance ---@type CacheController
  end

  local obj = get_obj("framework.model.cachemodel", "cachemodel") ---@type CacheModel
  setmetatable(obj, { __index = CacheController })
  CacheController.instance = obj
  return CacheController.instance ---@type CacheController
end

---@public
---@param self CacheController
---@param key string
---@return table
function CacheController:query(key)
  local memoize = CacheController.memoize
  if memoize[key] then
    return memoize[key]
  end

  memoize[key] = self:generic_fetch(key)

  return memoize[key]
end

return CacheController
