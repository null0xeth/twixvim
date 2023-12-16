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
local function get_obj(name, cacheKey, inheritance)
  local uninitialized_obj = get_module(name, cacheKey)
  if instance_cache[cacheKey] then
    return instance_cache[cacheKey]
  end

  if inheritance then
    instance_cache[cacheKey] = uninitialized_obj:new(inheritance)
    return instance_cache[cacheKey]
  end

  instance_cache[cacheKey] = uninitialized_obj:new()
  return instance_cache[cacheKey]
end

---@class DashboardController
local DashboardController = {}
DashboardController.__index = DashboardController
DashboardController.view = nil

function DashboardController:new()
  local obj = {}
  setmetatable(obj, DashboardController)
  DashboardController.view = get_obj("framework.view.dashboardview", "dashboardview", obj)
  return obj
end

-- Function Caching:
local rep = string.rep
local floor = math.floor

local function generate_button_description(button_description, button_len)
  local _string = rep(" ", 43 - button_len)
  return button_description .. _string
end

--> Helper function that waits for `Lazy` to be done, before opening the Dashboard
local function defer_dashboard_rendering()
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local is_lazy = vim.opt.filetype == "lazy"

  if is_lazy then
    local lazy = get_module("lazy", "lazy")
    autocmdcontroller:add_autocmd({
      event = "User",
      pattern = "DashboardLoaded",
      command_or_callback = function()
        lazy.show()
      end,
    })
  end
end

--> Helper function that converts startuptime to ms
--> and populates the corresponding section in the footer.
local function time_to_ms(startup_time)
  local first = (startup_time * 100 + 0.5)
  local second = floor(first)
  return (second / 100)
end

local function generate_buttons_template()
  local center = {
    { action = "Telescope find_files", desc = " Find file", icon = " ", key = "f" },
    { action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
    { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r" },
    { action = "Telescope live_grep", desc = " Find text", icon = " ", key = "g" },
    { action = "e $MYVIMRC", desc = " Config", icon = " ", key = "c" },
    { action = 'lua require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
    { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
    { action = "qa", desc = " Quit", icon = " ", key = "q" },
  }

  local len = #center
  for i = 1, len do
    local button = center[i]
    local b_len = #button.desc
    button.desc = generate_button_description(button.desc, b_len)
  end

  return center
end

--> Helper function that combines everything into the final footer
local function generate_footer_template()
  local lazy = get_module("lazy", "lazy")
  local stats = lazy.stats()
  local result = time_to_ms(stats.startuptime)
  local footer = "⚡Neovim loaded " .. stats.count .. " plugins in " .. result .. "ms"

  return footer
end

function DashboardController:initialize_dashboard()
  local footer = generate_footer_template()
  local center = generate_buttons_template()
  defer_dashboard_rendering()
  local template = self.view:render(center, footer)
  local dashboard = get_module("dashboard", "dashboard")
  dashboard.setup(template)
end

return DashboardController
