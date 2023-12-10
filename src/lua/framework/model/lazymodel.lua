---@class LazyModel
local LazyModel = {}
LazyModel.__index = LazyModel

-- [[ Caching Vim Functions ]] --

---@public
---@param self LazyModel
---@return LazyModel
function LazyModel:new()
  local obj = {}
  setmetatable(obj, self)
  return obj
end

---@protected
---@param self LazyModel
---@param plugins table
function LazyModel:lazy_load_plugins(plugins)
  --lazy_init()
  local lazy = require("lazy")
  lazy.setup(plugins, {
    defaults = {
      lazy = true, -- should plugins be lazy-loaded?
      version = nil,
    },
    change_detection = {
      notify = false,
    },
    install = {
      colorscheme = { "catppuccin" },
    },
    performance = {
      cache = {
        enabled = true,
      },
      rtp = {
        disabled_plugins = {
          "2html_plugin",
          "tohtml",
          "getscript",
          "getscriptPlugin",
          "gzip",
          "logipat",
          "netrw",
          "netrwPlugin",
          "netrwSettings",
          "netrwFileHandlers",
          "matchit",
          "tar",
          "tarPlugin",
          "rrhelper",
          "spellfile_plugin",
          "vimball",
          "vimballPlugin",
          "zip",
          "zipPlugin",
          "tutor",
          "rplugin",
          "syntax",
          "synmenu",
          "optwin",
          "compiler",
          "bugreport",
          "ftplugin",
        },
      },
    },
  })
end

return LazyModel
