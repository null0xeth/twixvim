local dapmodule = {}

-- Singleton Cache:
local moduleCache = {}

local function get_module(name, cacheKey)
  if moduleCache[cacheKey] then
    return moduleCache[cacheKey]
  end
  moduleCache[cacheKey] = require(name)
  return moduleCache[cacheKey]
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

dapmodule.get_dap_keys = memoize(function()
  local dap_instance = get_module("dap", "dap_instance")

  -- stylua: ignore
  local maps = {
    { "<leader>db", function() dap_instance.toggle_breakpoint() end, { desc = "Toggle Breakpoint" }},
    { "<leader>dB", function() dap_instance.set_breakpoint(vim.fn.input "[Condition] > ") end, {desc = "Conditional Breakpoint" }},
    { "<leader>dc", function() dap_instance.continue() end, {desc = "Continue" }},
    { "<leader>dC", function() dap_instance.run_to_cursor() end, {desc = "Run to Cursor" }},
    { "<leader>dd", function() dap_instance.disconnect() end, {desc = "Disconnect" }},
    { "<leader>dg", function() dap_instance.goto_() end, {desc = "Go to line (no execute)" }},
    { "<leader>di", function() dap_instance.step_into() end, {desc = "Step Into" }},
    { "<leader>dj", function() dap_instance.down() end, {desc = "Down" }},
    { "<leader>dk", function() dap_instance.up() end, {desc = "Up" }},
    { "<leader>dl", function() dap_instance.run_last() end, {desc = "Run Last" }},
    { "<leader>do", function() dap_instance.step_out() end, {desc = "Step Out" }},
    { "<leader>dO", function() dap_instance.step_over() end, {desc = "Step Over" }},
    { "<leader>dp", function() dap_instance.pause.toggle() end, {desc = "Pause" }},
    { "<leader>dq", function() dap_instance.close() end, {desc = "Quit" }},
    { "<leader>dr", function() dap_instance.repl.toggle() end, {desc = "Toggle REPL" }},
    { "<leader>ds", function() dap_instance.continue() end, {desc = "Start" }},
    { "<leader>dS", function() dap_instance.session() end, {desc = "Session" }},
    { "<leader>dt", function() dap_instance.terminate() end, {desc = "Terminate" }},
  }

  return maps
end)

dapmodule.get_dapui_keys = memoize(function()
  local dapui_instance = get_module("dapui", "dapui_instance")

  -- stylua: ignore
  local maps = {
     { "<leader>duo", function() dapui_instance.open() end, {desc = "Open UI", }},
     { "<leader>duc", function() dapui_instance.close() end, {desc = "Close UI", }},
     { "<leader>dufw", function() dapui_instance.float_element('watches', { enter = true }) end, { desc = "Float Watches"}},
     { "<leader>dufs", function() dapui_instance.float_element('scopes', { enter = true }) end, { desc = "Float Scopes"}},
     { "<leader>dufr", function() dapui_instance.float_element('repl', { enter = true }) end, { desc = "Float Repl"}},
  --set({'n', 'v'}, '<leader>dh', widgets.hover)
  --set({'n', 'v'}, '<leader>dp', widgets.preview)

  }

  return maps
end)

---Retrieves the path to codeLLDB and libLLDB from the Mason Registry
---@protected
---@return string: Returns the path to codeLLDB
---@return string: Returns the path to libLLDB
dapmodule.fetch_clldb = memoize(function()
  local extension_path = vim.env.HOME .. "/.vscode/extensions/vadimcn.vscode-lldb/"
  local codelldb_path = extension_path .. "adapter/codelldb"
  local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

  return codelldb_path, liblldb_path
end)

---Initialize and return the configuration for the codeLLDB DAP adapter
---@protected
dapmodule.init_rust_dap = memoize(function()
  local dap = get_module("dap", "dap_instance")
  -- stylua: ignore
  local function get_program() return vim.fn.input("program: ", vim.fn.expand("%f")) end
  -- stylua: ignore
  local function get_args() return vim.split(vim.fn.input("args: ", "", "file"), " ") end

  dap.configurations.c = {
    {
      type = "codelldb",
      request = "launch",
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      program = get_program,
      args = get_args,
    },
  }

  dap.configurations.cpp = dap.configurations.c
  dap.configurations.rust = dap.configurations.cpp
end)

dapmodule.init_lua_dap = memoize(function()
  local dap = get_module("dap", "dap_instance")
  dap.adapters.nlua = function(callback, conf)
    local adapter = {
      type = "server",
      host = conf.host or "127.0.0.1",
      port = conf.port or 8086,
    }

    if conf.start_neovim then
      local dap_run = dap.run
      dap.run = function(c)
        adapter.port = c.port
        adapter.host = c.host
      end

      require("osv").run_this()
      dap.run = dap_run
    end
    callback(adapter)
  end
  dap.configurations.lua = {
    {
      type = "nlua",
      request = "attach",
      name = "Run this file",
      start_neovim = {},
    },
    {
      type = "nlua",
      request = "attach",
      name = "Attach to running Neovim instance (port = 8086)",
      port = 8086,
    },
  }
end)

return dapmodule
