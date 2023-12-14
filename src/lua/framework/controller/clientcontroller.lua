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

---@class ClientController
local ClientController = {}
ClientController.__index = ClientController
setmetatable(
  ClientController,
  { __index = get_module("framework.controller.templatecontroller", "templatecontroller") }
)
ClientController.instance = nil

---@param self ClientController
---@return ClientController
function ClientController:new()
  local instance = ClientController.instance
  if instance then
    return instance
  end

  local obj = get_obj("framework.controller.templatecontroller", "templatecontroller")
  setmetatable(obj, { __index = ClientController })
  ClientController.instance = obj
  return obj
end

function ClientController:apply_template(type, path, key, instructions)
  self:render_template(type, path, key, instructions)
end

function ClientController:apply_autocmd_template()
  self:apply_template("autocmds", "template.autocmds_tpl", "autocmd", function(fetched_template)
    local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
    autocmdcontroller:batch_process_autocmds(fetched_template)
  end)
end

function ClientController:apply_keymap_template()
  self:apply_template("keymaps", "template.keymaps_tpl", "keymaps", function(fetched_template)
    local len = #fetched_template
    local keymapcontroller = get_obj("framework.controller.keymapcontroller", "keymapcontroller")
    keymapcontroller:initial_registration(fetched_template, len)
  end)
end

function ClientController:router(route)
  local routes = {
    keymaps = function()
      self:apply_keymap_template()
    end,
    autocmds = function()
      self:apply_autocmd_template()
    end,
  }
  routes[route]()
end

return ClientController
