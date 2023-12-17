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

-- Initialize LspController:
---@class LspController: LspModel
local LspController = {}
LspController.__index = LspController
setmetatable(LspController, { __index = get_module("framework.model.lspmodel", "lspmodel") })

-- Private Functions:
---Wraps the combined `custom` and `shared` onAttach logic in a callback and adds it to an autocmd.
---@package
---@param onAttach function: Callback-style function to be called on `LspAttach`
local function wrap_on_attach(onAttach)
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")

  local function on_attach_callback(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    onAttach(client, bufnr)
  end

  autocmdcontroller:add_autocmd({
    event = "LspAttach",
    command_or_callback = function(args)
      on_attach_callback(args)
    end,
  })
end

---@public
---@param self LspController
---@return LspController
function LspController:new()
  local obj = get_obj("framework.model.lspmodel", "lspmodel")
  setmetatable(obj, { __index = LspController })
  return obj
end

---Helper function that creates an autocommand for format- and lint on save
---@param self LspController
function LspController:lint_on_save(_, _)
  local lint = get_module("lint", "lint")
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local augroup = autocmdcontroller:add_augroup("AutoLint", { clear = true })
  autocmdcontroller:add_autocmd({
    event = { "BufEnter", "BufWritePost", "InsertLeave" },
    group = augroup,
    command_or_callback = function()
      lint.try_lint()
    end,
  })
end

---Combines the `shared` onAttach logic from "baseOnAttach" with custom onAttach logic
---@param self LspController
---@param customOnAttach? function
function LspController:custom_on_attach(customOnAttach)
  wrap_on_attach(function(client, bufnr)
    -- stylua: ignore
    if customOnAttach then
      customOnAttach(client, bufnr)
    end

    -- if client.server_capabilities.documentSymbolProvider then
    --   local navic = get_module("nvim-navic", "nvim-navic")
    --   navic.attach(client, bufnr)
    -- end

    --client.server_capabilities.semanticTokensProvider = nil
    local keymapcontroller = get_obj("framework.controller.keymapcontroller", "keymapcontroller")
    keymapcontroller:lsp_on_attach(client, bufnr)
    self:lint_on_save()
  end)
end

function LspController:get_capabilities()
  return self:fetch_capabilities()
end

local function process_mason(to_ensure)
  local mr = get_module("mason-registry", "mason-registry")
  local total_to_ensure = #to_ensure

  local function ensure_installed()
    for i = 1, total_to_ensure do
      --wrap_async_function(function()
      local pkg = mr.get_package(to_ensure[i])
      if not pkg:is_installed() then
        pkg:install()
      end
      --end)
    end
  end

  if mr.refresh then
    mr.refresh(ensure_installed)
  else
    ensure_installed()
  end
end

function LspController:setup_mason(opts)
  local mason = get_module("mason", "mason")
  mason.setup(opts)
  return process_mason(opts.ensure_installed)
end

--> Main orchestrator, handling LSP server set up.
---@param self LspController
---@param _ any
---@param opts table
---@param customAttach? function
function LspController:setup_lsp_servers(_, opts, customAttach)
  --local register_capability = vim.lsp.handlers["client/registerCapability"]

  -- vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
  --   local ret = register_capability(err, res, ctx)
  --   local client_id = ctx.client_id
  --   ---@type lsp.Client
  --   local client = vim.lsp.get_client_by_id(client_id)
  --   local buffer = vim.api.nvim_get_current_buf()
  --   --on_attach(client, buffer)
  --   return ret
  -- end
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

  -- for name, icon in pairs(lspSigns) do
  --   name = "DiagnosticSign" .. name
  --   vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  -- end

  -- local signLen = #lspSigns
  -- for i = 1, signLen do
  --   local sign = lspSigns[i]
  --   print("controller", vim.inspect(sign))
  --   vim.fn.sign_define(sign.name, { text = sign.text, texthl = sign.name, numhl = "" })
  -- end

  -- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  --   --signs = true,
  --   -- Enable underline, use default values
  --   underline = true,
  --   -- Enable virtual text, override spacing to 4
  --   virtual_text = {
  --     spacing = 4,
  --   },
  --   -- Use a function to dynamically turn signs off
  --   -- and on, using buffer local variables
  --   signs = function(namespace, bufnr)
  --     return vim.b[bufnr].show_signs == true
  --   end,
  --   -- Disable a feature
  --   update_in_insert = false,
  -- })

  self:custom_on_attach(customAttach)
  self:init_lsp_servers(opts)
end

function LspController:setup_glance()
  local glance = get_module("glance", "glance")
  local actions = glance.actions

  glance.setup({
    height = 25,
    list = { width = 0.35, position = "left" },
    detached = false,
    theme = { -- This feature might not work properly in nvim-0.7.2
      enable = true, -- Will generate colors for the plugin based on your current colorscheme
      mode = "auto", -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
    },
    preview_win_opts = { number = false, wrap = false },
    folds = { folded = false },
    indent_lines = { icon = " " },
    mappings = {
      list = {
        ["<C-CR>"] = actions.enter_win("preview"),
        ["j"] = actions.next_location, -- `.next` goes to next item, `.next_location` skips groups
        ["k"] = actions.previous_location,
        ["<PageUp>"] = actions.preview_scroll_win(5),
        ["<PageDown>"] = actions.preview_scroll_win(-5),
        -- consistent with the respective keymap for telescope
        ["<C-q>"] = function()
          actions.quickfix() -- leaves quickfix window open, so it's necessary to close it
          vim.cmd.cclose() -- cclose = quickfix-close
        end,
        -- ['<Esc>'] = false -- disable a mapping
      },
      preview = {
        ["q"] = actions.close,
        ["<Tab>"] = actions.next_location,
        ["<S-Tab>"] = actions.previous_location,
        ["<leader>l"] = actions.enter_win("list"), -- Focus list window
      },
    },
    hooks = {
      before_open = function(results, open, jump, method)
        -- filter out current line, if references
        if method == "references" then
          local curLn = vim.fn.line(".")
          local curUri = vim.uri_from_bufnr(0)
          results = vim.tbl_filter(function(result)
            local targetLine = result.range.start.line + 1 -- LSP counts off-by-one
            local targetUri = result.uri or result.targetUri
            local notCurrentLine = (targetLine ~= curLn) or (targetUri ~= curUri)
            return notCurrentLine
          end, results)
        end

        -- jump directly if there is only one references
        if #results == 0 then
          vim.notify("No " .. method .. " found.")
        elseif #results == 1 then
          jump(results[1])
        else
          open(results)
        end
      end,
    },
  })
end

return LspController
