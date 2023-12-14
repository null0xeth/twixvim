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

---@class DapController: DapModel
local DapController = {}
DapController.__index = DapController
setmetatable(DapController, { __index = get_module("framework.model.dapmodel", "dapmodel") })

-- stays here
-- local function register_which_key()
--   local wk = get_module("which-key", "which_key")
--   wk.register({
--     ["<leader>da"] = { "+Adapters" },
--     ["<leader>du"] = {
--       name = "+DAP UI",
--       v = { "+Virtual Text" },
--       w = { "+UI Widgets" },
--     },
--   })
-- end

---@package
---@param ... table[] Tables containing keymaps
local function register_dap_keys(...)
  local args = { ... }
  local argc = #args
  local keymapcontroller = get_obj("framework.controller.keymapcontroller", "keymapcontroller")

  for i = 1, argc do
    local t = args[i]
    local keymaps_in_arg = #t

    for j = 1, keymaps_in_arg do
      local map = t[j]
      keymapcontroller:register_keymap("n", map[1], map[2], map[3])
    end
  end
end

---@protected
---@param self DapController
function DapController:setup_nvim_dap()
  local combined_keys = self:init_nvim_dap()
  register_dap_keys(combined_keys.dap, combined_keys.dapui)
  --register_which_key()
end

---@public
---@param self DapController
---@return DapController obj
function DapController:new()
  local obj = get_obj("framework.model.dapmodel", "dapmodel") ---@type DapModel
  setmetatable(obj, { __index = DapController })
  return obj ---@type DapController
end

return DapController
