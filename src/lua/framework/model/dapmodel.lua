---@class DapModel
local DapModel = {}
DapModel.__index = DapModel

-- Singleton Cache:
local module_cache = {}
local instance_cache = {}

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

---@protected
---@param fetch_func function @The specific function from dapmodule to call
---@return any @Returns the result from the specific fetch function
local function fetch_from_dapmodule(fetch_func)
  local dapmodule = get_module("framework.model.modules.dapmodule", "dapmodule")
  return fetch_func(dapmodule)
end

-- to dapmodel
local function setup_nvim_dap(callback)
  local dap_instance = get_module("dap", "dap_instance")
  local cachecontroller = get_obj("framework.controller.cachecontroller", "cachecontroller")
  local icons = cachecontroller:query("icons")

  --vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

  for name, sign in pairs(icons.dap) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define(
      "Dap" .. name,
      { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
    )
    --vim.fn.sign_define("Dap" .. name, { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = "", numhl = "" })
  end

  dap_instance.set_log_level("info")

  callback()
end

-- to dap model
local function setup_nvim_dap_ui()
  local dap_instance = get_module("dap", "dap_instance")
  local dapui_instance = get_module("dapui", "dapui_instance")

  dap_instance.listeners.after.event_initialized["dapui_config"] = function()
    dapui_instance.open()
  end
  dap_instance.listeners.before.event_terminated["dapui_config"] = function()
    dapui_instance.close({})
  end
  dap_instance.listeners.before.event_exited["dapui_config"] = function()
    dapui_instance.close({})
  end

  dapui_instance.setup({
    icons = { expanded = "", collapsed = "", current_frame = "" },
    mappings = {
      -- Use a table to apply multiple mappings
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    element_mappings = {},
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    force_buffers = true,
    layouts = {
      {
        -- You can change the order of elements in the sidebar
        elements = {
          -- Provide IDs as strings or tables with "id" and "size" keys
          {
            id = "scopes",
            size = 0.25, -- Can be float or integer > 1
          },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks", size = 0.25 },
          { id = "watches", size = 0.25 },
        },
        size = 40,
        position = "left", -- Can be "left" or "right"
      },
      {
        elements = {
          "repl",
          "console",
        },
        size = 10,
        position = "bottom", -- Can be "bottom" or "top"
      },
    },
    floating = {
      max_height = nil,
      max_width = nil,
      border = "single",
      mappings = {
        ["close"] = { "q", "<Esc>" },
      },
    },
    controls = {
      enabled = vim.fn.exists("+winbar") == 1,
      element = "repl",
      icons = {
        pause = "",
        play = "",
        step_into = "",
        step_over = "",
        step_out = "",
        step_back = "",
        run_last = "",
        terminate = "",
        disconnect = "",
      },
    },
    render = {
      max_type_length = nil, -- Can be integer or nil.
      max_value_lines = 100, -- Can be integer or nil.
      indent = 1,
    },
  })

  -- dap_instance.listeners.after.event_initialized["dapui_config"] = function()
  --   dapui_instance.open()
  -- end
  -- dap_instance.listeners.before.event_terminated["dapui_config"] = function()
  --   dapui_instance.close({})
  -- end
  -- dap_instance.listeners.before.event_exited["dapui_config"] = function()
  --   dapui_instance.close({})
  -- end

  --vim.g.dap_virtual_text = true
end

local function wrap_callback()
  --dev.wrap(setup_nvim_dap, 1)(setup_nvim_dap_ui)
  setup_nvim_dap(setup_nvim_dap_ui)
end

---Fetch the path to the codeLLDB compiler from the Mason Registry
---@protected
---@param self DapModel
---@return function
function DapModel:get_codelldb()
  return fetch_from_dapmodule(function(dapmodule)
    return dapmodule.fetch_clldb()
  end)
end

---Initialize and return the configuration for the nlua DAP adapter
---@param self DapModel
function DapModel:get_lua_dap()
  -- stylua: ignore
  fetch_from_dapmodule(function(dapmodule) return dapmodule.init_lua_dap() end)
end

---Initialize the configuration for the codeLLDB DAP adapter
---@param self DapModel
function DapModel:setup_rust_dap()
  -- stylua: ignore
  fetch_from_dapmodule(function(dapmodule) return dapmodule.init_rust_dap() end)
end

function DapModel:get_rust_adapter()
  local codelldb_path, _ = self:get_codelldb()
  return {
    type = "server",
    port = "13000",
    executable = {
      command = codelldb_path,
      --args = { "--liblldb", liblldb_path, "--port", "13000" },
      args = { "--port", "13000" },
      name = "rt_lldb",
    },
  }
end

function DapModel:init_nvim_dap()
  wrap_callback()
  local dapmodule = get_module("framework.model.modules.dapmodule", "dapmodule")
  local combined_keys = {
    dap = dapmodule.get_dap_keys(),
    dapui = dapmodule.get_dapui_keys(),
  }

  return combined_keys
end

---@public
---@param self DapModel
---@return DapModel obj
function DapModel:new()
  local obj = {}
  setmetatable(obj, DapModel)
  return obj ---@type DapModel
end

return DapModel
