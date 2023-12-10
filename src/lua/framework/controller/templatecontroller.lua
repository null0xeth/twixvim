local module_cache = setmetatable({}, { __mode = "kv" })
local template_cache = setmetatable({}, { __mode = "kv" })
template_cache.settings = nil
template_cache.keymaps = nil

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

local function wrap_async_function(func)
  local dev = get_module("util.libraries.test", "dev")
  return dev.create(func, 0)
end

local function delegate_async_function(func)
  wrap_async_function(func)()
end

local TemplateController = {}
TemplateController.__index = TemplateController

function TemplateController:new()
  local obj = {}
  setmetatable(obj, TemplateController)
  return obj
end

local function fetch_template(category, path, key)
  if not template_cache[category] then
    local result = get_module(path, key)
    template_cache[category] = result
  end
  return template_cache[category]
end

function TemplateController:render_template(category, path, key, instructions)
  local fetched_template = {}
  --delegate_async_function(function()
  fetched_template = fetch_template(category, path, key)
  if instructions then
    instructions(fetched_template)
    return
  end
  --end)
  return fetched_template
end

return TemplateController
