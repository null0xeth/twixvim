---@class StateView: StateController
local StateView = {}
StateView.__index = StateView

---@public
---@param self StateView
---@param controller StateController
---@return StateView
function StateView:new(controller)
  local obj = { controller = controller }
  setmetatable(obj, { __index = StateView })
  return obj ---@type StateView
end

---@protected
---@param self StateView
function StateView:render()
  local showDiagnostics = self.controller:is_diagnostics_active()
  if showDiagnostics then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end

return StateView
