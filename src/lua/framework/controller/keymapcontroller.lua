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

local keymap = vim.keymap.set

local function process_opts(opts)
  local tbl = {}
  local options = {
    "buffer",
    "exp",
    "silent",
    "noremap",
    "desc",
  }

  for i = 1, #opts do
    local item = opts[i]
    if vim.tbl_contains(options, opts[i]) then
      table.insert(tbl, opts[i])
    end
  end
  print(vim.inspect(tbl))
end

---@class KeymapController
local KeymapController = {}
KeymapController.__index = KeymapController
KeymapController.instance = nil

---@public
---@param self KeymapController
---@return KeymapController obj
function KeymapController:new()
  local instance = KeymapController.instance
  if instance then
    return instance
  end

  --local obj = {} ---@type KeymapController
  local obj = setmetatable({}, KeymapController) ---@type KeymapController
  KeymapController.instance = obj
  return obj
end

function KeymapController:register_whichkey(opts)
  local wk = get_module("which-key", "which-key")
  wk.register(opts)
end

function KeymapController:initial_registration(table, len)
  local data = table
  for i = 1, len do
    --wrap_async_function(function()
    local map = data[i]
    self:register_keymap(map[1], map[2], map[3], { desc = map[4], noremap = true, silent = true })
    --end)
  end
end

function KeymapController:batch_register_keymaps(table, len)
  local data = table
  for i = 1, len do
    --wrap_async_function(function()
    local map = data[i]
    self:register_keymap(map[1], map[2], map[3], map[4])
    --end)
  end
end

---Register a given keymap, using Nvim's API.
---@param self KeymapController
---@param mode string|nil
---@param lhs string
---@param rhs string|function
---@param opts table|nil
function KeymapController:register_keymap(mode, lhs, rhs, opts)
  mode = mode or "n"
  opts = opts and opts or { silent = true }
  keymap(mode, lhs, rhs, opts)
end

---Convert the data in the parameters to LSP keymap format and register it.
---@param self KeymapController
---@param mode string
---@param lhs string
---@param rhs string
---@param opts table
function KeymapController:register_lsp_keymap(mode, lhs, rhs, opts)
  local rhs_cmd = type(rhs) == "string" and ("<cmd>%s<cr>"):format(rhs) or rhs
  self:register_keymap(mode, lhs, rhs_cmd, {
    silent = true,
    buffer = opts.buffer,
    expr = opts.expr,
    desc = opts.desc,
  })
end

---Register the default LSP keymaps and attach them to a buffer.
---@param self KeymapController
---@param _ any
---@param buffer integer
function KeymapController:lsp_on_attach(_, buffer)
  vim.schedule(function()
    local keymapmodule = get_module("framework.model.modules.keymapmodule", "keymapmodule")
    local mappings = keymapmodule.get_default_lsp_keymaps()
    local len = #mappings
    for i = 1, len do
      local map = mappings[i]
      local opts = {
        desc = map[3],
        buffer = buffer,
      }
      self:register_keymap("n", map[1], map[2], opts)
    end
  end)
end

return KeymapController
