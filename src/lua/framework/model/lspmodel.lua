local module_cache = {}
local memoize = {}

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

---This class abstracts the logic for setting up LSP servers.
---@class LspModel
local LspModel = {}
LspModel.__index = LspModel

---Fetch or initialize the default LSP server capabilities
---@protected
---@param self LspModel: Instance of LspModel
---@return table: Returns a table containing default LSP server capabilities
function LspModel:fetch_capabilities()
  if memoize["capabilities"] then
    return memoize["capabilities"]
  end

  local lspmodule = get_module("framework.model.modules.lspmodule", "lspmodule")
  memoize["capabilities"] = lspmodule.set_default_capabilities()
  return memoize["capabilities"]
end

---Orchestrates the initialization and configuration of LSP servers
---@protected
---@param self LspModel
---@param opts table: Lua table containing setup instructions for various LSP servers
function LspModel:init_lsp_servers(opts)
  -- [[ Set up the LSP servers: ]] --
  assert(opts, "`opts` cannot be nil") -- Verify that `opts` are not nil
  local lspmodule = get_module("framework.model.modules.lspmodule", "lspmodule")
  lspmodule.process_lsp_servers(opts)
end

---@public
---@param self LspModel
---@return LspModel obj
function LspModel:new()
  local obj = {}
  setmetatable(obj, self)
  return obj
end

return LspModel
