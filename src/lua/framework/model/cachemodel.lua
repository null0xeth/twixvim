local instance_cache = {}
local module_cache = {}

-- Enumerations for query routing:
local enums = {
  languages = "base",
  colorschemes = "base",
  icons = "icons",
}

-- Caching:
local pairs = pairs
local contains = vim.tbl_contains

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

-- [[##########################]] --
--          Initialization        --
-- [[##########################]] --

---@class CacheModel
local CacheModel = {}
CacheModel.__index = CacheModel
CacheModel.template_cache = {}
CacheModel.config_cache = {}
CacheModel.lru_cache = {}

-- [[##########################]] --
--        Private Functions       --
-- [[##########################]] --
-- local function wrap_async_function(func)
--   local dev = get_module("util.libraries.test", "dev")
--   dev.create(func, 0)()
-- end

-- local function delegate_async_function(func)
--   wrap_async_function(func)
-- end

---@public
---@param self CacheModel
---@return CacheModel obj
function CacheModel:new()
  local obj = {}
  setmetatable(obj, CacheModel)
  return obj
end

-- works
local function cacheActiveItems(args)
  local activeItems = {}
  local cacheItem = args[2]
  --print(vim.inspect(cache_item))
  for item, isActive in pairs(cacheItem) do
    --delegate_async_function(function()
    if isActive then
      activeItems[#activeItems + 1] = item
    end
    --end)
  end
  return activeItems
end

-- solid, dont touch
local function fetch_routes(key)
  local identifier = enums[key]
  local prerequisites = {
    base = {
      category = "settings",
      path = "config",
      route = cacheActiveItems,
    },
    icons = {
      category = "icons",
      path = "template.icons_tpl",
    },
  }
  return prerequisites[identifier]
end

local function item_exists(key, table)
  if contains(table, key) then
    return true
  end
end

local function delegate_processing(key, prerequisites, config)
  local route = prerequisites.route
  local result
  local args = { key, config }

  if not route then
    return config
  end

  --wrap_async_function(function()
  result = route(args)
  --end)
  return result
end

local function new_generic_fetch(key, argc, ...)
  local args = { ... }
  local lru_cached = CacheModel.lru_cache
  local config_cached = CacheModel.config_cache
  local template_cached = CacheModel.template_cache

  local prerequisites = fetch_routes(key)
  local category = prerequisites.category
  local path = prerequisites.path

  if argc < 1 and item_exists(key, lru_cached) then
    return lru_cached[key]
  end

  if argc == 1 then
    config_cached[key] = key ~= "icons" and template_cached[category][key] or template_cached[category]
    return new_generic_fetch(key, 2, config_cached[key], prerequisites)
  end

  if argc == 2 then
    --wrap_async_function(function()
    local cached_config = args[1]
    local prereqs = args[2]
    lru_cached[key] = delegate_processing(key, prereqs, cached_config)
    --end)
    return lru_cached[key]
  end

  if item_exists(key, config_cached) then
    --wrap_async_function(function()
    lru_cached[key] = delegate_processing(key, prerequisites, config_cached[key])
    --end)
    return lru_cached[key]
  end

  if template_cached[category] then
    config_cached[key] = key ~= "icons" and template_cached[category][key] or template_cached[category]
    return new_generic_fetch(key, 2, config_cached[key], prerequisites)
  end

  local template
  --wrap_async_function(function()
  local templatecontroller = get_obj("framework.controller.templatecontroller", "templatecontroller")
  template = templatecontroller:render_template(category, path, category)
  template_cached[category] = template
  --end)
  return new_generic_fetch(key, 1, template)
end

local memoize = {}
function CacheModel:generic_fetch(key)
  if memoize[key] then
    return memoize[key]
  end

  --wrap_async_function(function()
  memoize[key] = new_generic_fetch(key, 0)
  --end)

  return memoize[key]
end

return CacheModel
