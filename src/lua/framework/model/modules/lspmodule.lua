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
local diagnostic, sign_define = vim.diagnostic, vim.fn.sign_define

---@package
---Initializes the LSP config and assigns icons to the various LSP symbols.
local function init_lsp_config() --= memoize(function()
  local cachecontroller = get_obj("framework.controller.cachecontroller", "cachecontroller")
  local iconCache = cachecontroller:query("icons")
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    virtual_text = false,
    -- enables lsp_lines but we want to start disabled
    virtual_lines = false,
    -- show signs
    signs = {
      text = signs,
    },
    update_in_insert = false,
    underline = true,
    severity_sort = false,
    float = {
      focus = false,
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)
  -- local lspSigns = {
  --   { name = "DiagnosticSignError", text = "" },
  --   { name = "DiagnosticSignWarn", text = "" },
  --   { name = "DiagnosticSignHint", text = "" },
  --   { name = "DiagnosticSignInfo", text = "" },
  -- }
  -- local lspSigns = {
  --   Error = "",
  --   Warn = "",
  --   Hint = "",
  --   Info = "",
  -- }

  -- local lspConfig = {
  --   --float = { focusable = true, style = "minimal", border = "rounded" },
  --   diagnostic = {
  --     -- signs = {
  --     --   text = {
  --     --     [vim.diagnostic.severity.ERROR] = "",
  --     --     [vim.diagnostic.severity.WARN] = "",
  --     --     [vim.diagnostic.severity.INFO] = "",
  --     --     [vim.diagnostic.severity.HINT] = "",
  --     --   },
  --     -- },
  --     virtual_text = { severity = { min = diagnostic.severity.ERROR } },
  --     --virtual_text = false,
  --     underline = false,
  --     update_in_insert = false,
  --     severity_sort = true,
  --     float = {
  --       focusable = true,
  --       style = "minimal",
  --       border = "rounded",
  --       source = "always",
  --       header = "",
  --       prefix = "",
  --     },
  --   },
  -- }

  -- local signLen = #lspSigns
  -- for i = 1, signLen do
  --   local sign = lspSigns[i]
  --   print("module", vim.inspect(sign))
  --   sign_define(sign.name, { text = sign.text, texthl = sign.name, numhl = "" })
  -- end
  -- for name, icon in pairs(lspSigns) do
  --   name = "DiagnosticSign" .. name
  --   vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  -- end

  --vim.diagnostic.config(lspConfig.diagnostic)
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
