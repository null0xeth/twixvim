---@class StateModel
local StateModel = {}
StateModel.__index = StateModel
StateModel.states = {
  diagnostics_active = true,
  auto_format = true,
  auto_lint = true,
}

---@public
---@param self StateModel
---@return StateModel
function StateModel:new()
  local obj = {}
  setmetatable(obj, StateModel)
  return obj ---@type StateModel
end

---@public
---@param self StateModel
---@return table
function StateModel:get_all_states()
  local states = self.states
  return states
end

function StateModel:toggle_diagnostics()
  self.states.diagnostics_active = not self.states.diagnostics_active
end

function StateModel:is_diagnostics_active()
  return self.states.diagnostics_active
end

function StateModel:is_autoformat_enabled()
  return self.states.auto_format
end

function StateModel:is_autoLint_enabled()
  return self.states.auto_lint
end

return StateModel
