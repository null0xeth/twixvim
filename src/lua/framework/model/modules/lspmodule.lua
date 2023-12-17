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

local function wrap_async_function(func)
  local dev = get_module("util.libraries.test", "dev")
  return dev.create(func, 0)
end

local function delegate_async_function(func)
  wrap_async_function(func)()
end

---@class lspmodule
local lspmodule = {}

local deepExtend = vim.tbl_deep_extend

---@package
---Initializes the LSP config and assigns icons to the various LSP symbols.
local function init_lsp_config() --= memoize(function()
  local cachecontroller = get_obj("framework.controller.cachecontroller", "cachecontroller")

  local signs = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = "",
  }

  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.diagnostic.config({
    virtual_lines = true,
    -- virtual_text = {
    --   source = "always",
    --   prefix = "■",
    -- },
    virtual_text = false,
    float = {
      source = "always",
      border = "rounded",
      format = function(diagnostic)
        if diagnostic.source == "" then
          return diagnostic.message
        end
        if diagnostic.source == "eslint" then
          return string.format(
            "%s [%s]",
            diagnostic.message,
            -- shows the name of the rule
            diagnostic.user_data.lsp.code
          )
        end
        --return string.format("%s [%s]", diagnostic.message, diagnostic.source)
        return string.format("%s", diagnostic.message)
      end,
      suffix = function()
        return ""
      end,
      severity_sort = true,
      close_events = { "CursorMoved", "InsertEnter" },
    },
    signs = {
      severity = vim.diagnostic.severity.WARN,
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
      texthl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
    },
    underline = false,
    update_in_insert = false,
    severity_sort = true,
  })
end

---@package
---@param opts table|function: A table with setup instructions for LSP servers
---@return table: A map-like structure with setup instructions for LSP servers
---Helper function that translates opts to an array with LSP servers
local function convert_opts_to_map(opts)
  local serverSetups = {}
  local servers = opts.servers
  local setup = opts.setup
  local serversLen = #servers

  for i = 1, serversLen do
    local server = servers[i]
    serverSetups[server] = setup[server] or setup["*"]
  end
  return serverSetups
end

---Initializes the default LSP capabilities if not already initialized.
---@protected
---@return table defaultCapabilities: Returns a table containing the default LSP server capabilities
lspmodule.set_default_capabilities = memoize(function()
  local cmp = get_module("cmp_nvim_lsp", "cmp_nvim_lsp")
  return cmp.default_capabilities()
end)

---Configure and set up an individual LSP server
---@package
---@param server string: The name of the LSP server
---@param serverOpts table: A lua table containing configurations for this LSP server
---@param serverSetup table: A slice of serverSetups for this particular LSP server
local function setup_lsp_server(server, serverOpts, serverSetup)
  local default_capabilities = lspmodule.set_default_capabilities()

  -- Deep extend options
  serverOpts = deepExtend("force", {
    capabilities = default_capabilities,
  }, serverOpts)

  -- Use the directly passed serverSetup function
  if serverSetup then
    if serverSetup(server, serverOpts) then
      return
    end
  end

  -- Fallback to default setup if no custom setup is provided
  require("lspconfig")[server].setup(serverOpts)
end

---Take an array of LSP servers and initialize them.
---@protected
---@param opts table: A lua table containing LSP server configurations
function lspmodule.process_lsp_servers(opts)
  init_lsp_config()

  -- Convert opts.servers[] and opts.setup[] to a map-like structure:
  local sSetups = convert_opts_to_map(opts)

  local servers = opts.servers
  --delegate_async_function(function()
  for server, s_opts in pairs(servers) do
    --wrap_async_function(function()
    if s_opts then
      s_opts = s_opts == true and {} or s_opts
      setup_lsp_server(server, s_opts, sSetups[server])
    end
    --end)()
  end
  --end)
end

return lspmodule
