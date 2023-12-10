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

---@class AutoCmdController: AutoCmdModel
---This class extends `AutoCmdModel` and acts as a public interface to interact with it's methods.
local AutoCmdController = {}
AutoCmdController.__index = AutoCmdController
setmetatable(AutoCmdController, { __index = get_module("framework.model.autocmdmodel", "autocmdmodel") })
AutoCmdController.instance = nil

---@public
---@param self AutoCmdController
---@return AutoCmdController obj
function AutoCmdController:new()
  local instance = AutoCmdController.instance
  if instance then
    return instance ---@type AutoCmdController
  end

  local obj = get_obj("framework.model.autocmdmodel", "autocmdmodel")
  setmetatable(obj, { __index = AutoCmdController })
  AutoCmdController.instance = obj
  return obj ---@type AutoCmdController
end

---@protected
---@param autoCmds table: An array <lua_table> containing autocmd configurations
---Function that takes an array of autocmds, iterates over it and passes the individual autocmds along to other Class methods for processing
function AutoCmdController:batch_process_autocmds(autoCmds)
  local len = #autoCmds
  for i = 1, len do
    self:add_autocmd(autoCmds[i])
  end
end

---@public
---@param opts table: Table containing various configuration options for autocmds (group, buffer, command_or_callback, ...)
---Function that takes a given configuration map for an autocmd, processes it and registers the corresponding autocmd.
function AutoCmdController:add_autocmd(opts)
  local keyParts = {}

  if opts.group and opts.group ~= "" then
    table.insert(keyParts, opts.group)
  end

  if opts.buffer and opts.buffer ~= "" then
    table.insert(keyParts, opts.buffer)
  end

  -- Add events to key if they exist
  if opts.event then
    local events = type(opts.event) == "table" and table.concat(opts.event, ",") or opts.event
    table.insert(keyParts, events)
  end

  -- Add patterns to key if they exist
  if opts.pattern then
    local patterns = type(opts.pattern) == "table" and table.concat(opts.pattern, ",") or opts.pattern
    table.insert(keyParts, patterns)
  end

  local key = table.concat(keyParts, ",")
  if key ~= "" then
    self:register_autocmd(key, opts.event, opts.pattern, opts)
  end
end

---@public
---@param name string: Augroup name
---@param opts table: Augroup configuration options.
---Function that takes an augroup name and configuration options, and passes it on for registration.
function AutoCmdController:add_augroup(name, opts)
  return self:register_augroup(name, opts)
end

function AutoCmdController:remove_augroup(name)
  self:delete_augroup(name)
end

function AutoCmdController:execute_autocmd(event, opts)
  local api = vim.api
  api.nvim_exec_autocmds(event, opts)
end

return AutoCmdController
