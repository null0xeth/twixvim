local instance_cache = {}
local module_cache = {}

local routes = {
  core = {
    config = "lazy.core.config",
    plugin = "lazy.core.plugin",
    cache = "lazy.core.cache",
    util = "lazy.core.util",
  },
  event = {
    handler = "lazy.core.handler.event",
  },
}

local schedule = vim.schedule

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

---@class EngineControllerInterface: EngineController
local iEngine = {}
iEngine.__index = iEngine
setmetatable(iEngine, { __index = get_module("framework.controller.enginecontroller", "enginecontroller") })

function iEngine:new()
  local obj = get_obj("framework.controller.enginecontroller", "enginecontroller")
  setmetatable(obj, { __index = iEngine })
  return obj
end

local function is_plugin_loaded(plugin, and_processed)
  local lazy_core_config = get_module(routes.core.config, "lazy_core_config")
  local config_spec = lazy_core_config.spec.plugins[plugin]
  local is_loaded = lazy_core_config.spec.plugins[plugin] ~= nil

  local result = and_processed and (is_loaded and config_spec._.loaded) or is_loaded
  return result
end

function iEngine:very_lazy_function(fn)
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  autocmdcontroller:add_autocmd({
    event = "User",
    pattern = "VeryLazy",
    command_or_callback = vim.schedule_wrap(function()
      pcall(fn)
    end),
  })
end

function iEngine:await_plugin(plugin_name, fn)
  --local lazy_core_config = get_module(routes.core.config, "lazy_core_config")
  local is_plugin_loaded_and_processed = is_plugin_loaded(plugin_name, true)
  --if lazy_core_config.plugins[plugin_name] and lazy_core_config.plugins[plugin_name]._.loaded then
  if is_plugin_loaded_and_processed then
    fn(plugin_name)
  else
    local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
    autocmdcontroller:add_autocmd({
      event = "User",
      pattern = "LazyLoad",
      command_or_callback = function(event)
        if event.data == plugin_name then
          fn(plugin_name)
          return true
        end
      end,
    })
  end
end

function iEngine:is_plugin_loaded(plugin)
  return is_plugin_loaded(plugin, false)
end

function iEngine:fetch_opts(plugin_name)
  local fetched_plugin = is_plugin_loaded(plugin_name, false)

  if not fetched_plugin then
    return {}
  end

  local lazy_core_plugin = get_module(routes.core.plugin, "lazy_core_plugin")
  return lazy_core_plugin.values(fetched_plugin, "opts", false)
end

return iEngine
