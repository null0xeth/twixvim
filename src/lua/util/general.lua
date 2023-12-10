local instance_cache = {}
local module_cache = {}

local core_config_path = "lazy.core.config"
local core_plugin_path = "lazy.core.plugin"
local core_cache_path = "lazy.core.cache"
local core_util_path = "lazy.core.util"
local event_handler_path = "lazy.core.handler.event"

-- Caching vim functions:
local api = vim.api
local bo = vim.bo

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

local M = {
  did_init_rtp = false,
  did_init_plugins = false,
  event_enum = { "BufReadPost", "BufNewFile", "BufWritePre" },
  kinda_lazy = true,
}

-- added elsewhere
function M.configure_rtp()
  if M.did_init_rtp then
    return
  end

  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  vim.opt.rtp:prepend(lazypath)
  package.path = package.path .. ";/home/null0x/.local/share/nvim/lazy/lazy.nvim/lua/?.lua"

  M.did_init_rtp = true
end

function M.is_loaded(plugin)
  local lazy_core_config = get_module(core_config_path, "lazy_core_config")
  return lazy_core_config.spec.plugins[plugin] ~= nil
end

function M.fetch_opts(plugin_name)
  local lazy_core_config = get_module(core_config_path, "lazy_core_config")
  local fetched_plugin = lazy_core_config.plugins[plugin_name]

  if not fetched_plugin then
    return {}
  end

  local lazy_core_plugin = get_module(core_plugin_path, "lazy_core_plugin")
  return lazy_core_plugin.values(fetched_plugin, "opts", false)
end

-- moved
function M.kinda_lazy_load()
  M.kinda_lazy = M.kinda_lazy and vim.fn.argc(-1) > 0
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")

  -- Add support for the LazyFile event
  local lazy_event_handler = get_module(event_handler_path, "lazy_event_handler")

  if M.kinda_lazy then
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

  local done = false
  local function load()
    if #events == 0 or done then
      return
    end
    done = true

    autocmdcontroller:remove_augroup("KindaLazyGang")

    ---@type table<string,string[]>
    local skips = {}
    for _, event in ipairs(events) do
      skips[event.event] = skips[event.event] or lazy_event_handler.get_augroups(event.event)
    end

    autocmdcontroller:execute_autocmd("User", { pattern = "KindaLazy", modeline = false })

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

  local augroup = autocmdcontroller:add_augroup("KindaLazyGang", { clear = true })
  local autocmd_events = M.event_enum
  autocmdcontroller:add_autocmd({
    event = autocmd_events,
    group = augroup,
    command_or_callback = function(event)
      table.insert(events, event)
      load()
    end,
  })
end

-- moved
function M.very_lazy_function(fn)
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  autocmdcontroller:add_autocmd({
    event = "User",
    pattern = "VeryLazy",
    command_or_callback = function()
      fn()
    end,
  })
end

-- moved
function M.on_plugin_loaded(plugin_name, fn)
  local lazy_core_config = get_module(core_config_path, "lazy_core_config")
  if lazy_core_config.plugins[plugin_name] and lazy_core_config.plugins[plugin_name]._.loaded then
    fn(plugin_name)
  else
    local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
    autocmdcontroller:add_autocmd({
      event = "User",
      pattern = "LazyLoad",
      command_or_callback = function(event)
        if event.data == plugin_name then
          fn(plugin_name)
          return true
        end
      end,
    })
  end
end

-- try is from lazy.core.util
-- moved
local function find_and_load_module(name, query, is_obj)
  local lazy_core_cache = get_module(core_cache_path, "lazy_core_cache")
  local found_in_cache = lazy_core_cache.find(query)[1]

  if found_in_cache then
    local lazy_core_util = get_module(core_util_path, "lazy_core_util")
    lazy_core_util.try(function()
      if is_obj then
        local clientcontroller = get_obj("framework.controller.clientcontroller", "clientcontroller")
        clientcontroller:router(name)
      else
        require(query)
      end
    end, { msg = "Failed loading " .. name })
  end
end

---@param name "autocmds" | "options" | "keymaps"
-- moved
function M.load(name, is_obj)
  local query = is_obj and "framework.controller.clientcontroller" or "config." .. name

  find_and_load_module(name, query, is_obj)

  if vim.bo.filetype == "lazy" then
    vim.cmd([[do VimResized]])
  end

  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local pattern = "Neovim" .. name:sub(1, 1):upper() .. name:sub(2)
  autocmdcontroller:execute_autocmd("User", { pattern = pattern, modeline = false })
end

-- delay notifications till vim.notify was replaced or after 500ms
-- moved
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.loop.new_timer()
  local check = assert(vim.loop.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

-- moved
function M.init()
  if M.did_init_plugins then
    return
  end
  M.did_init_plugins = true
  --M.configure_rtp()

  M.lazy_notify()

  M.load("options", false)

  M.kinda_lazy_load()
end

-- moved
function M.setup()
  M.configure_rtp()
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local automatically_lazy = vim.fn.argc(-1) == 0
  if not automatically_lazy then
    M.load("autocmds", true)
  end

  local augroup = autocmdcontroller:add_augroup("Neovim", { clear = true })
  autocmdcontroller:add_autocmd({
    event = "User",
    group = augroup,
    pattern = "VeryLazy",
    command_or_callback = function()
      if automatically_lazy then
        M.load("autocmds", true)
      end

      M.load("keymaps", true)
    end,
  })

  local lazy_core_util = get_module(core_util_path, "lazy_core_util")
  lazy_core_util.track("colorscheme")
  lazy_core_util.try(function()
    vim.cmd.colorscheme("catppuccin")
  end, { msg = "Failed to load colorscheme" })
  lazy_core_util.track()
end

return M
