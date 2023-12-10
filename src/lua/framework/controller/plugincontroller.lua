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

local function wrap_async_function(func)
  local dev = get_module("util.libraries.test", "dev")
  return dev.create(func, 0)
end

local function delegate_async_function(func)
  wrap_async_function(func)()
end

---Define the pluginController
---@class PluginController: PluginModel
local PluginController = {}
PluginController.__index = PluginController
setmetatable(PluginController, { __index = get_module("framework.model.pluginmodel", "pluginmodel") })

---pluginController constructor
---@public
---@param self PluginController
---@return PluginController
function PluginController:new()
  local obj = get_obj("framework.model.pluginmodel", "pluginmodel")
  setmetatable(obj, { __index = PluginController })
  obj.lazymodel = get_obj("framework.model.lazymodel", "lazymodel")
  return obj
end

---@param self PluginController
function PluginController:initialize_plugins()
  local plugins = {}
  --delegate_async_function(function()
  plugins = self:fetch_all_plugins()
  --end)
  --delegate_async_function(function()
  self.lazymodel:lazy_load_plugins(plugins)
  --end)
end

return PluginController
