-- Local Configuration Variables:
local configuration = {
  lazy_installed = false,
  rtp_initialized = false,
  plugins_initialized = false,
  registered_kinda_lazy = true,
}

local package_configuration = {
  base = ";/home/null0x/.local/share/nvim/lazy/lazy.nvim/lua/?.lua",
}

-- Lazy library routes:
local routes = {
  core = {
    config = "lazy.core.config",
    plugin = "lazy.core.plugin",
    cache = "lazy.core.cache",
    util = "lazy.core.util",
  },
  event = {
    handler = "lazy.core.handler.event",
  },
}

-- Local Enums:
local enums = {
  events = { "BufReadPost", "BufNewFile", "BufWritePre" },
}

local vim = vim
local fn = vim.fn
local schedule = vim.schedule
local cmd = vim.cmd
local loop = vim.loop
local api = vim.api
local bo = vim.bo

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

---@class EngineController: PluginController
local EngineController = {}
EngineController.__index = EngineController
setmetatable(EngineController, { __index = get_module("framework.controller.plugincontroller", "plugincontroller") })

---@public
---@return EngineController obj
function EngineController:new()
  local obj = get_obj("framework.controller.plugincontroller", "plugincontroller")
  setmetatable(obj, { __index = EngineController })
  return obj
end

local function install_lazy()
  if configuration.lazy_installed then
    return
  end

  local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
  local has_lazy = loop.fs_stat(lazypath)
  if not has_lazy then
    fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  configuration.lazy_installed = true
  return
end

local function wrap_async_function(func)
  local dev = require("util.libraries.test")
  return dev.create(func, 0)
end

local function schedule_wrapper(func)
  return vim.schedule_wrap(func)
end

-- Higher Order Functions:
local function try(fun)
  local lazy_core_util = get_module(routes.core.util, "lazy_core_util")
  lazy_core_util.try(fun, { msg = "Failed loading " .. "yeet" })
end

-- local function controller_interface(instance, func, args)
--   instance[func](instance, args)
-- end

-- local function autocmd_adapter(func, args)
--   local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
--   controller_interface(autocmdcontroller, func, args)
-- end

local function wrap_router(condition, query)
  if not condition then
    try(function()
      require(query)
    end)
  else
    vim.schedule(function()
      try(function()
        local clientcontroller = get_obj("framework.controller.clientcontroller", "clientcontroller")
        clientcontroller:router(query)
      end)
    end)
  end
end
--end

-- Package Level Functions:
local function find_and_load_module(name, query, is_obj)
  local lazy_core_cache = get_module(routes.core.cache, "lazy_core_cache")
  local found_in_cache = lazy_core_cache.find(query)[1]

  if not found_in_cache then
    return
  end

  local request = is_obj and name or query
  wrap_router(is_obj, request)
end

local function extend_package_path()
  local package_path = package.path
  local new_package_path = package_path .. package_configuration.base
  return new_package_path
end

---@package
---@return boolean configuration.rtp_initialized
local function is_rtp_initialized()
  return configuration.rtp_initialized
end

local function initialize_rtp()
  if is_rtp_initialized() then
    return
  end

  local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
  vim.opt.rtp:prepend(lazypath)
  package.path = extend_package_path()

  configuration.rtp_initialized = true
end

local function setup_kinda_lazy()
  configuration.registered_kinda_lazy = configuration.registered_kinda_lazy and vim.fn.argc(-1) > 0
  -- Add support for the LazyFile event
  local lazy_event_handler = get_module(routes.event.handler, "lazy_event_handler")

  if configuration.registered_kinda_lazy then
    -- We'll handle delayed execution of events ourselves
    lazy_event_handler.mappings.KindaLazy = { id = "KindaLazy", event = "User", pattern = "KindaLazy" }
    lazy_event_handler.mappings["User KindaLazy"] = lazy_event_handler.mappings.KindaLazy
  else
    -- Don't delay execution of LazyFile events, but let lazy know about the mapping
    lazy_event_handler.mappings.KindaLazy = { id = "KindaLazy", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
    lazy_event_handler.mappings["User KindaLazy"] = lazy_event_handler.mappings.KindaLazy
    return
  end

  local events = {} ---@type {event: string, buf: number, data?: any}[]
  local is_done = false

  local function load()
    if #events == 0 or is_done then
      return
    end

    is_done = true
    local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
    autocmdcontroller:remove_augroup("KindaLazyGang")
    --autocmd_adapter("remove_augroup", "KindaLazyGang")

    ---@type table<string,string[]>
    local skips = {}
    for _, event in ipairs(events) do
      skips[event.event] = skips[event.event] or lazy_event_handler.get_augroups(event.event)
    end

    autocmdcontroller:execute_autocmd("User", { pattern = "KindaLazy", modeline = false })
    --autocmd_adapter("execute_autocmd", { "User", { pattern = "KindaLazy", modeline = false } })

    for _, event in ipairs(events) do
      if api.nvim_buf_is_valid(event.buf) then
        lazy_event_handler.trigger({
          event = event.event,
          exclude = skips[event.event],
          data = event.data,
          buf = event.buf,
        })
        if bo[event.buf].filetype then
          lazy_event_handler.trigger({
            event = "FileType",
            buf = event.buf,
          })
        end
      end
    end

    autocmdcontroller:execute_autocmd("CursorMoved", { modeline = false })
    events = {}
  end

  -- schedule wrap so that nested autocmds are executed
  -- and the UI can continue rendering without blocking
  load = vim.schedule_wrap(load)

  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local augang = autocmdcontroller:add_augroup("KindaLazyGang", { clear = true })

  --local augroup = autocmd_adapter("add_augroup", { "KindaLazyGang", { clear = true } })
  local autocmd_events = enums.events
  --autocmd_adapter("add_autocmd", {
  autocmdcontroller:add_autocmd({
    event = autocmd_events,
    group = augang,
    command_or_callback = function(event)
      table.insert(events, event)
      load()
    end,
  })
end

local function load_module(name, is_obj)
  local query = is_obj and "framework.controller.clientcontroller" or "config." .. name
  local is_lazy = (bo.filetype == "lazy")

  local wrapper = schedule_wrapper(function()
    local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
    local pattern = "Neovim" .. name:sub(1, 1):upper() .. name:sub(2)
    autocmdcontroller:execute_autocmd("User", { pattern = pattern, modeline = false })
  end)

  local lazy_wrapper = schedule_wrapper(function()
    cmd([[do VimResized]])
  end)

  find_and_load_module(name, query, is_obj)

  if is_lazy then
    lazy_wrapper()
  end

  wrapper()
end

local function lazy_notify()
  --  schedule(function()
  local notifs = {}
  local replay

  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = loop.new_timer()
  local check = assert(loop.new_check())

  replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    ---@diagnostic disable-next-line: no-unknown
    for _, notif in ipairs(notifs) do
      vim.notify(vim.F.unpack_len(notif))
    end
    --end)
  end

  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  timer:start(500, 0, replay)
end

local function init_plugins()
  lazy_notify()
  load_module("options", false)
  setup_kinda_lazy()
end

local function init_engine()
  local automatically_lazy = vim.fn.argc(-1) == 0
  if not automatically_lazy then
    load_module("autocmds", true)
  end

  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local augroup = autocmdcontroller:add_augroup("Neovim", { clear = true })
  autocmdcontroller:add_autocmd({
    event = "User",
    group = augroup,
    pattern = "VeryLazy",
    command_or_callback = function()
      if automatically_lazy then
        load_module("autocmds", true)
      end
      load_module("keymaps", true)
      --end)
    end,
  })
  -- TODO: Reswap
  local lazy_core_util = get_module(routes.core.util, "lazy_core_util")
  lazy_core_util.track("colorscheme")
  lazy_core_util.try(function()
    schedule(function()
      cmd.colorscheme("catppuccin")
    end)
  end, { msg = "Failed to load colorscheme" })
  lazy_core_util.track()
end

function EngineController:initialize_nvim()
  install_lazy()
  initialize_rtp()
  init_engine()
  init_plugins()
  self:initialize_plugins()
end

return EngineController
