local instance_cache = setmetatable({}, { __mode = "kv" })
local module_cache = setmetatable({}, { __mode = "kv" })

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

local uicontroller = require("framework.controller.uicontroller")
local NavigationController = uicontroller:new()
NavigationController.__index = NavigationController

function NavigationController:new()
  local obj = {}
  setmetatable(obj, self)
  return obj
end

-- Caching:
local tbl_filter = vim.tbl_filter
local fn = vim.fn

-- [[ Buf Functions ]] --
local function get_tab_number(winnr)
  return vim.api.nvim_win_get_tabpage(winnr) -- B
end

local function get_buf_info(winnr)
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  return vim.fn.getbufinfo(bufnr)[1]
end

local function fetch_win_list(tabnr)
  local tabpage_win_list = vim.api.nvim_tabpage_list_wins(tabnr)
  return tabpage_win_list
end

local function fetch_tab_wins(tabnr, winnr)
  local win_list = fetch_win_list(tabnr)
  local tab_wins = tbl_filter(function(w)
    return w ~= winnr
  end, win_list) -- B
  return tab_wins
end

local function is_nvim_tree(var)
  return var.name:match(".*NvimTree_%d*$")
end

local function fetch_tab_bufs(winnr)
  local tabnr = get_tab_number(winnr) -- B
  local tab_wins = fetch_tab_wins(tabnr, winnr)
  return vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins), tab_wins
end

local function fetch_last_buf(tab_bufs)
  return vim.fn.getbufinfo(tab_bufs[1])[1]
end

local function tab_win_closed(winnr)
  local api = get_module("nvim-tree.api", "nvim-tree.api")
  local buf_info = get_buf_info(winnr)
  local tab_bufs, tab_wins = fetch_tab_bufs(winnr)
  local is_empty = vim.tbl_isempty(tab_bufs)

  if is_nvim_tree(buf_info) then -- close buffer was nvim tree
    -- Close all nvim tree on :q
    if not is_empty then -- and was not the last window (not closed automatically by code below)
      api.tree.close()
    end
  else -- else closed buffer was normal buffer
    if #tab_bufs == 1 then -- if there is only 1 buffer left in the tab
      local last_buf_info = fetch_last_buf(tab_bufs)
      local is_last = #vim.api.nvim_list_wins() == 1

      if is_nvim_tree(last_buf_info) then -- and that buffer is nvim tree
        vim.schedule(function()
          if is_last then -- if its the last buffer in vim
            vim.cmd("quit") -- then close all of vim
          else -- else there are more tabs open
            vim.api.nvim_win_close(tab_wins[1], true) -- then close only the tab
          end
        end)
      end
    end
  end
end

local function create_autocmd()
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local schedule_wrap = vim.schedule_wrap
  local winnr = tonumber(fn.expand("<amatch>"))
  autocmdcontroller:add_autocmd({
    event = "WinClosed",
    command_or_callback = function()
      schedule_wrap(function()
        tab_win_closed(winnr)
      end)
    end,
  })
end
function NavigationController:setup()
  local tree = get_module("nvim-tree", "nvimtree")
  create_autocmd()
  tree.setup({
    sync_root_with_cwd = true,
    root_dirs = {},
    prefer_startup_root = false,
    reload_on_bufenter = false,
    respect_buf_cwd = false,
    on_attach = "default",
    auto_reload_on_write = false,
    disable_netrw = false,
    hijack_cursor = false,
    hijack_netrw = true,
    hijack_unnamed_buffer_when_opening = false,

    view = {
      adaptive_size = true,
      width = 24,
    },
    git = {
      enable = false,
      ignore = true,
    },
    filesystem_watchers = {
      enable = true,
      debounce_delay = 50,
      ignore_dirs = {},
    },
    actions = {
      use_system_clipboard = false,
      open_file = {
        resize_window = false,
        quit_on_open = false,
        window_picker = {
          enable = true,
          picker = "default",
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame" },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
      remove_file = {
        close_window = true,
      },
      change_dir = {
        enable = true,
        global = true,
        restrict_above_cwd = false,
      },
    },
    trash = {
      cmd = "trash",
      require_confirm = true,
    },
    tab = {
      sync = {
        open = false,
        close = false,
        ignore = {},
      },
    },
    diagnostics = {
      enable = false,
      show_on_dirs = true,
      icons = { hint = "", info = "", warning = "", error = "" },
    },
    renderer = {
      group_empty = false,
      highlight_git = false,
      root_folder_label = function()
        local curdir = fn.fnamemodify(vim.fn.expand("%"), ":p:h:t")
        local pardir = fn.fnamemodify(vim.fn.expand("%"), ":p:h:h:t")
        return "../" .. pardir .. "/" .. curdir
      end,
      indent_markers = {
        enable = false,
        inline_arrows = true,
      },
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = false,
        },

        webdev_colors = true,
        git_placement = "before",
        padding = " ",
        symlink_arrow = " ➛ ",

        glyphs = {
          default = "󰈚",
          symlink = "",
          folder = {
            default = "",
            empty = "",
            empty_open = "",
            open = "",
            symlink = "",
            symlink_open = "",
            arrow_open = "",
            arrow_closed = "",
          },
          git = {
            unstaged = "✗",
            staged = "✓",
            unmerged = "",
            renamed = "➜",
            untracked = "★",
            deleted = "",
            ignored = "◌",
          },
        },
      },
    },
    update_focused_file = {
      enable = true,
      debounce_delay = 15,
      ignore_list = {},
      update_root = true,
    },
    filters = {
      dotfiles = false,
      custom = { "^.git$", "^node_modules$", "^.DS_Store$" },
    },
    log = {
      enable = false,
      types = {
        diagnostics = true,
      },
    },
    system_open = {
      cmd = nil,
      args = {},
    },
    sort_by = "case_sensitive",
    hijack_directories = {
      enable = false,
      auto_open = true,
    },
  })
end

return NavigationController
