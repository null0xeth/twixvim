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

local CodingController = {}
CodingController.__index = CodingController
setmetatable(CodingController, { __index = get_module("framework.controller.cachecontroller", "cachecontroller") })

function CodingController:new()
  local obj = get_obj("framework.controller.cachecontroller", "cachecontroller")
  setmetatable(obj, { __index = CodingController })
  return obj
end

function CodingController:setup_treeshitter(opts)
  assert(type(opts.ensure_installed) == "table", "ensure_installed is not a table")

  local repl_highlights = get_module("nvim-dap-repl-highlights", "repl_highlights")
  repl_highlights.setup()

  local treesitter_config = get_module("nvim-treesitter.configs", "treesitter_config")

  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.updatetime = 100

  local added = {}
  opts.ensure_installed = vim.tbl_filter(function(lang)
    if added[lang] then
      return false
    end
    added[lang] = true
    return true
  end, opts.ensure_installed)

  treesitter_config.setup(opts)
  require("ts_context_commentstring").setup()
  vim.g.skip_ts_context_commentstring_module = true
end

return CodingController
