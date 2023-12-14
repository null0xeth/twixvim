local instance_cache = {}
local module_cache = {}

---@class keymapmodule
local keymapmodule = {}

local fn = vim.fn
local diagnostic = vim.diagnostic

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

-- Memoization with closure:
local function memoize(f)
  local cache = {}
  return function()
    if cache[1] then
      return unpack(cache)
    end
    cache = { f() }
    return unpack(cache)
  end
end

---@param next boolean
---@param severity? string
---@return function
local function diagnostic_goto(next, severity)
  local go = next and diagnostic.goto_next or diagnostic.goto_prev
  severity = severity and diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

local function rename_lsp_buf()
  if pcall(require, "inc_rename") then
    return ":IncRename " .. fn.expand("<cword>")
  else
    vim.lsp.buf.rename()
  end
end

-- add grep_string, quickfix, reloader, buffers, autocmds, diagnostics
---@public
---@return table default_lsp_keymaps
keymapmodule.get_default_lsp_keymaps = memoize(function()
  local telescope_builtin = get_module("telescope.builtin", "telescope_builtin")
  local statecontroller = get_obj("framework.controller.statecontroller", "statecontroller")
  -- stylua: ignore
  local default_lsp_keymaps =
  {
    { "gd", function() telescope_builtin.lsp_definitions { reuse_win = true } end, "Goto Definition" }, -- works
    { "gr", function() telescope_builtin.lsp_references { reuse_win = true } end, "References" }, -- works
    { "gD", "<cmd>Lspsaga peek_definition<cr>", "Peek Definition" }, -- works
    { "gI", function() telescope_builtin.lsp_implementations { reuse_win = true } end, "Goto Implementation" }, --works
    { "gy", function() telescope_builtin.lsp_type_definitions { reuse_win = true } end, "Goto Type Definition" },
    --{ "K", "<cmd>Lspsaga hover_doc<cr>", "Hover" }, --works
    { "K", function() vim.lsp.buf.hover() end, "view documentation" },
    { "gK", function() vim.lsp.buf.signature_help() end, "Signature Help" }, -- works
    { "]d", diagnostic_goto(true), "Next Diagnostic" }, --works
    { "[d", diagnostic_goto(false),"Prev Diagnostic" }, --works
    { "]e", diagnostic_goto(true, "ERROR"),"Next Error" }, --works
    { "[e", diagnostic_goto(false, "ERROR"), "Prev Error" }, --works
    { "]w", diagnostic_goto(true, "WARNING"), "Next Warning" }, --works
    { "[w", diagnostic_goto(false, "WARNING"), "Prev Warning" }, --works
    { "<leader>lc", "<cmd>Lspsaga code_action<cr>", "Code Action", "CodeAction (LSP)"}, --works
    { "<leader>lr", function() rename_lsp_buf() end, "Rename Buf (LSP)"}, -- no clue
    { "<leader>vso", "<cmd>SymbolsOutline<cr>", "Document Symbols" }, -- works
    { "<leader>lw", function() telescope_builtin.lsp_dynamic_workspace_symbols() end, "Workspace Symbols (LSP)" }, --works
    { "<leader>cw", function() statecontroller:render_diagnostics() end, "Toggle Inline Diagnostics" }, --works
  }
  return default_lsp_keymaps
end)

return keymapmodule
