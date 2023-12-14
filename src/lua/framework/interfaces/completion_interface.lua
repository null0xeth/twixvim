local instance_cache = setmetatable({}, { __mode = "kv" })
local module_cache = setmetatable({}, { __mode = "kv" })

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

local iCompletion = {}
iCompletion.__index = iCompletion

function iCompletion:new()
  local obj = {}
  setmetatable(obj, iCompletion)
  return obj
end

function iCompletion:setup_nvim_cmp()
  local completioncontroller = get_obj("framework.controller.completioncontroller", "completioncontroller")
  completioncontroller:initialize_cmp()
end

function iCompletion:setup_crates()
  local completioncontroller = get_obj("framework.controller.completioncontroller", "completioncontroller")
  completioncontroller:initialize_crates()
end

return iCompletion
