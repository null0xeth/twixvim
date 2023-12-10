---@class AutoCmdModel
local AutoCmdModel = {}
AutoCmdModel.__index = AutoCmdModel
AutoCmdModel.activeAutoCmds = {}
AutoCmdModel.activeAugroups = {}

local api = vim.api

---@public
---@param self AutoCmdModel
---@return AutoCmdModel obj
function AutoCmdModel:new()
  local obj = {} ---@type AutoCmdModel
  setmetatable(obj, self)
  return obj
end

---@protected
---@param key string: Unique identifier used to look up a given autocmd in `self.activeAutoCmds`
---@param event string: Neovim event that will trigger the given autocmd.
---@param pattern string: Pattern that will trigger the autocmd when matched.
---@param opts table: Table containing various configuration options for autocmds (group, buffer, command_or_callback, ...)
---Helper function that checks whether an instance of an autocmd already exists and registers it with the Neovim API in case it does not.
function AutoCmdModel:register_autocmd(key, event, pattern, opts)
  if self.activeAutoCmds[key] then
    return
  end

  local command = opts.command_or_callback
  local cmd_type = type(command)

  if cmd_type ~= "string" and cmd_type ~= "function" then
    error("[ERROR]: Invalid command or callback type")
  end

  local cmd_config = {
    pattern = pattern,
    group = opts.group,
    buffer = opts.buffer,
  }

  if cmd_type == "string" then
    cmd_config.command = command --opts.command_or_callback
  else
    cmd_config.callback = command --opts.command_or_callback
  end

  if not event and (not cmd_config.command or not cmd_config.callback) then
    error("[ERROR]: Missing required fields (event, command/callback)")
  end

  api.nvim_create_autocmd(event, cmd_config)
  self.activeAutoCmds[key] = true
end

---@protected
---@param name string: Augroup name
---@param opts table: Augroup configuration options.
---Function that takes an augroup name and configuration options and registers it.
function AutoCmdModel:register_augroup(name, opts)
  if self.activeAugroups[name] then
    return
  end

  local augroup_config = {
    clear = opts.clear or false, -- Default to false if not provided
    -- Add other augroup options here
  }

  api.nvim_create_augroup(name, augroup_config)

  -- Mark the Augroup as active
  self.activeAugroups[name] = true
  return name
end

function AutoCmdModel:delete_augroup(name)
  api.nvim_del_augroup_by_name(name)
  if self.activeAugroups[name] then
    self.activeAugroups[name] = false
  end
end

return AutoCmdModel
