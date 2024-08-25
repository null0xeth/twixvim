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
local function get_obj(name, cacheKey)
  local uninitialized_obj = get_module(name, cacheKey)
  if instance_cache[cacheKey] then
    return instance_cache[cacheKey]
  end

  instance_cache[cacheKey] = uninitialized_obj:new()
  return instance_cache[cacheKey]
end

local function define_augroup(name, opts)
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  return autocmdcontroller:add_augroup(name, opts)
end

-- [[ Caching Vim Functions: ]] --
local vim = vim
local fn = vim.fn
local wo = vim.wo
local bo = vim.bo
local vaapi = vim.api
local highlight = vim.highlight
local schedule = vim.schedule
local diagnostic = vim.diagnostic
local vim_cmd = vim.cmd

vaapi.nvim_set_hl(0, "TerminalCursorShape", { underline = true })
local is_neo = vim.bo.filetype == "neo-tree"
local is_dashh = vim.bo.filetype == "dashboard"

vim.filetype.add({
  extension = { rasi = "rasi" },
  pattern = {
    [".*/waybar/config"] = "jsonc",
    [".*/mako/config"] = "dosini",
    [".*/kitty/*.conf"] = "bash",
  },
})
vim.filetype.add({
  extension = { rasi = "rasi" },
  pattern = {
    [".*/waybar/config"] = "jsonc",
    [".*/mako/config"] = "dosini",
    [".*/kitty/*.conf"] = "bash",
  },
})

local cmds = {
  {
    event = "FileType",
    pattern = { "neo-tree", "dashboard" },
    command_or_callback = function()
      if is_dashh or is_neo then
        vim.opt.statusline = " "
      else
        vim.opt.laststatus = 3
      end
    end,
  },
  -- --> Disable focus when certain conditions are met:
  -- {
  --   group = define_augroup("FocusDisable", { clear = true }),
  --   event = "WinEnter",
  --   command_or_callback = function(_)
  --     if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
  --       vim.w.focus_disable = true
  --     else
  --       vim.w.focus_disable = false
  --     end
  --   end,
  --   desc = "Disable focus autoresize for BufType",
  -- },

  -- {
  --   group = define_augroup("FocusDisable", { clear = true }),
  --   event = "FileType",
  --   command_or_callback = function(_)
  --     if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
  --       vim.b.focus_disable = true
  --     else
  --       vim.b.focus_disable = false
  --     end
  --   end,
  --   desc = "Disable focus autoresize for FileType",
  -- },
  {
    event = "FileType",
    pattern = "dap-repl",
    command_or_callback = function(args)
      vim.api.nvim_buf_set_option(args.buf, "buflisted", false)
    end,
  },
  --> Show highlighted text on yank
  {
    group = define_augroup("YankHighlight", { clear = true }),
    event = "TextYankPost",
    pattern = "*",
    command_or_callback = function()
      highlight.on_yank()
    end,
  },
  -- Auto resize splits if window got resized
  {
    event = "VimResized",
    group = define_augroup("resize_splits", { clear = true }),
    command_or_callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  },
  {
    event = { "FocusGained", "TermClose", "TermLeave" },
    group = define_augroup("checktime", { clear = true }),
    command_or_callback = function()
      if vim.o.buftype ~= "nofile" then
        vim.cmd("checktime")
      end
    end,
  },
  -- Big file support
  {
    event = "FileType",
    pattern = "bigfile",
    group = define_augroup("bigfile", { clear = true }),
    command_or_callback = function(event)
      vim.b.minianimate_disable = true
      vim.schedule(function()
        vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
      end)
    end,
  },
  -- go to last loc when opening a buffer
  {
    event = "BufReadPost",
    pattern = "*",
    group = define_augroup("last_loc", { clear = true }),
    command_or_callback = function(event)
      local exclude = { "gitcommit" }
      local buf = event.buf
      if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].my_last_loc then
        return
      end
      vim.b[buf].my_last_loc = true
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  },
  {
    event = "FileType",
    pattern = {
      "OverseerForm",
      "OverseerList",
      "checkhealth",
      "man",
      "startuptime",
      "toggleterm",
      "tsplayground",
      "vim",
      "PlenaryTestPopup",
      "grug-far",
      "help",
      "lspinfo",
      "notify",
      "qf",
      "spectre_panel",
      "startuptime",
      "tsplayground",
      "neotest-output",
      "checkhealth",
      "neotest-summary",
      "neotest-output-panel",
      "dbout",
      "gitsigns.blame",
    },
    command_or_callback = function(event)
      vim.bo[event.buf].buflisted = false
      local keymapcontroller = get_obj("framework.controller.keymapcontroller", "keymapcontroller")

      keymapcontroller:register_keymap("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  },
  --> Only show cursor in active windows
  {
    event = { "InsertLeave", "WinEnter" },
    command_or_callback = function()
      local ok, cl = pcall(vaapi.nvim_win_get_var, 0, "auto-cursorline")
      if ok and cl then
        wo.cursorline = true
        vaapi.nvim_win_del_var(0, "auto-cursorline")
      end
    end,
  },
  --> ... continued
  {
    event = { "InsertEnter", "WinLeave" },
    command_or_callback = function()
      local cl = wo.cursorline
      if cl then
        vaapi.nvim_win_set_var(0, "auto-cursorline", cl)
        wo.cursorline = false
      end
    end,
  },
  --> ... continued
  {
    event = "TermEnter",
    command_or_callback = function()
      vim_cmd([[setlocal winhighlight=TermCursor:TerminalCursorShape]])
    end,
  },
  --> ... continued
  {
    event = "VimLeave",
    command_or_callback = function()
      vim_cmd([[set guicursor=a:ver25]])
    end,
  },
  --> Show diagnostics in float window.
  {
    event = "CursorHold",
    command_or_callback = function()
      local statecontroller = get_obj("framework.controller.statecontroller", "statecontroller")
      local showDiagnostics = statecontroller:is_diagnostics_active()
      if showDiagnostics then
        schedule(diagnostic.open_float)
      end
    end,
  },
  --> Show bufferline when >= 2 buffers open.
  {
    group = define_augroup("ToggleBufferline", { clear = true }),
    event = { "BufNewFile", "BufRead", "TabEnter" },
    pattern = "*",
    command_or_callback = function()
      --vim.opt.showtabline = 0
      if #fn.getbufinfo({ buflisted = 1 }) >= 2 then
        vim.opt.showtabline = 2
      end
    end,
  },
  --> Close bufferline when <= 1 buffers open.
  {
    group = define_augroup("ToggleBufferline", { clear = true }),
    event = "BufDelete",
    pattern = "*",
    command_or_callback = function()
      vim.defer_fn(function()
        if #fn.getbufinfo({ buflisted = 1 }) <= 1 then
          vim.opt.showtabline = 0
        end
      end, 50)
    end,
  },
}

return cmds
