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

---@class StateController: StateModel
local StateController = {}
StateController.__index = StateController
setmetatable(StateController, { __index = get_module("framework.model.statemodel", "statemodel") })
StateController.view = nil

---@public
---@param self StateController
---@return StateController
function StateController:new()
  local obj = get_obj("framework.model.statemodel", "statemodel")
  setmetatable(obj, { __index = StateController })
  obj.view = get_obj("framework.view.stateview", "stateview", obj)
  return obj ---@type StateController
end

---@public
---@param self StateController
function StateController:render_diagnostics()
  self:toggle_diagnostics()
  self.view:render()
end

---@public
---@param self StateController
---@return table
function StateController:fetch_all_states()
  --return self.states
  return self:get_all_states()
end

return StateController
