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

local uicontroller = require("framework.controller.uicontroller")
local TelescopeController = uicontroller:new()
TelescopeController.__index = TelescopeController

function TelescopeController:new()
  local obj = {}
  setmetatable(obj, self)
  return obj
end

local function _load_extension(extension_name)
  local telescope = get_module("telescope", "telescope")
  telescope.load_extension(extension_name)
end

local hiddenIgnoreActive = false
local findFileMappings = {
  -- toggle `--hidden` & `--no-ignore`
  ["<C-h>"] = function(prompt_bufnr)
    local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
    -- cwd is only set if passed as telescope option
    local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
    hiddenIgnoreActive = not hiddenIgnoreActive
    local title = vim.fs.basename(cwd)
    if hiddenIgnoreActive then
      title = title .. " (--hidden --no-ignore)"
    end

    require("telescope.actions").close(prompt_bufnr)
    require("telescope.builtin").find_files({
      prompt_title = title,
      hidden = hiddenIgnoreActive,
      no_ignore = hiddenIgnoreActive,
      cwd = cwd,
      file_ignore_patterns = { "%.DS_Store$", "%.git/" }, -- prevent these becoming visible through `--no-ignore`
    })
  end,
  -- search directory up
  ["<D-up>"] = function(prompt_bufnr)
    local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
    -- cwd is only set if passed as telescope option
    local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
    local parent_dir = vim.fs.dirname(cwd)

    require("telescope.actions").close(prompt_bufnr)
    require("telescope.builtin").find_files({
      prompt_title = vim.fs.basename(parent_dir),
      cwd = parent_dir,
    })
  end,
}

-- local function load_telescope_extensions()
--   local extensions = {
--     "command_palette",
--     "neoclip",
--   }

--   for i = 1, #extensions do
--     --delegate_async_function(function()
--     _load_extension(extensions[i])
--     --end)
--   end
-- end

local function fetch_telescope_mappings()
  local telescope = get_module("telescope", "telescope")
  local tb = get_module("telescope.builtin", "tb")
  local te = telescope.extensions
  -- stylua: ignore
  local maps = {
    --{"<leader>fgn", function() te.neoclip.default() end, "NeoClip"},
    {"<space>fgr", function() tb.registers() end, "Registers"},
    {"<leader>fgp", function() tb.resume() end, "Resume last Picker"},
    {"<leader>fgc", function() tb.commands { results_title = "Commands Results" } end, "Telescope Commands" },
    {"<leader>fgm", function() tb.marks { results_title = "Marks Results" } end, "Marks"},
    {"<leader>fgt", function() tb.help_tags { results_title = "Help Results" } end, "Help Tags" },
    {"<leader>fzg", function() tb.live_grep() end, "Live Grep"},
    {"<leader>fzl", function() tb.live_grep { grep_open_files = true } end, "Live Grep (Open Files)"},
    {"<leader>fzc", function() tb.current_buffer_fuzzy_find() end, "Current Buffer FZF"},
    {"<leader>fzs", function() tb.grep_string() end, "Grep word under cursor"},
    {"<leader>fzS", function() tb.grep_string { word_match = "-w" } end, "Grep word under cursor (CS)"},
    {"<leader>fzk", function() tb.keymaps { results_title = "Key Maps Results" } end, "Telescope Keymaps"},
    {"<leader>fdw", function() tb.diagnostics() end, "Workspace Diagnostics"},
    {"<leader>fli", function() tb.lsp_implementations() end, "Lsp Implementations"},
    {"<leader>fff", function() tb.find_files { find_command = { "fd", "--no-ignore-vcs" } } end, "Find Files"},
    --{"<space>fp", function() te.command_palette.command_palette() end, "Command Palette"},
    {"<space>fGl", function() tb.git_commits() end, "Git commits (Log)"},
    {"<space>fGs", function() tb.git_status() end, "Git status"},
    {"<leader>fld", function() tb.lsp_document_symbols() end, "Lsp Document Symbols"},
    {"<leader>fgh", function() te.notify.notify { results_title = "Notification History", prompt_title = "Search Messages" } end, "Nvim Notify History" },
    {"<leader>ffo", function() tb.oldfiles { prompt_title = ":oldfiles", results_title = "Old Files" } end, "Oldfiles" },
    {"<space>fGb", function() tb.git_branches { prompt_title = " ", results_title = "Git Branches" } end, "Git Branches" },
    {"<space>fGc", function() tb.git_bcommits { prompt_title = "  ", results_title = "Git File Commits" } end, "Git commits (with diff)" },
    -- stylua: ignore
    {"<leader>fzb", function() tb.buffers { prompt_title = "", results_title = "﬘", winblend = 3, layout_strategy = "vertical", layout_config = { width = 0.60, height = 0.55 } } end, "Buffers" },
    -- stylua: ignore
    {"<leader>fld", function() tb.lsp_definitions { layout_config = { preview_width = 0.50, width = 0.92 }, path_display = { "shorten" }, results_title = "Definitions" } end, "Lsp Definitions" },
  }
  return maps
end

local function telescope_path_display(_, path)
  path = path:gsub("/$", "") -- trailing slash from directories breaks fs.basename
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
  if parent == "." then
    return tail
  end
  local parentDisplay = #parent > 20 and vim.fs.basename(parent) or parent
  return string.format("%s    %s", tail, parentDisplay) -- parent colored via autocmd above
end

local function telescope_path_autocmd()
  -- HACK color parent as comment
  -- CAVEAT interferes with other Telescope Results that display for spaces
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "TelescopeResults",
    callback = function()
      vim.fn.matchadd("TelescopeParent", "    .*$")
      vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
    end,
  })
end

local function generate_template()
  local actions = get_module("telescope.actions", "telescope_actions")
  local template = {
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case", -- this is default
      },
    },
    defaults = {
      path_display = telescope_path_display,
      selection_caret = "❯ ",
      multi_icon = " ",
      results_title = false,
      dynamic_preview_title = true,
      preview = {
        timeout = 400,
        filesize_limit = 1, -- Mb
        ls_short = true, -- ls is only used when displaying directories
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
      },
      prompt_prefix = "❯ ",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      color_devicons = true,
      --layout_strategy = "cursor",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          height = 0.75,
          width = 0.99,
          preview_cutoff = 70,
          preview_width = { 0.55, min = 30 },
        },
      },
      mappings = {
        n = {
          ["<Del>"] = actions.close,
          ["q"] = actions.close,
          ["<Esc>"] = actions.close,
          --["<C-A>"] = M.telescope_custom_actions.multi_selection_open,
        },
      },
      winblend = 4,
    },
    pickers = {
      find_files = {
        prompt_prefix = "󰝰 ",
        -- FIX using the default find command from telescope is somewhat buggy,
        -- e.g. not respecting /fd/ignore
        find_command = { "fd", "--type=file", "--type=symlink" },
        mappings = { i = findFileMappings },
      },
      live_grep = { prompt_prefix = " ", disable_coordinates = true },
      git_bcommits = {
        prompt_prefix = "󰊢 ",
        initial_mode = "normal",
        layout_config = { horizontal = { height = 0.99 } },
        git_command = { "git", "log", "--pretty=%h %s\t%cr" }, -- add commit time (%cr)
      },
      keymaps = {
        prompt_prefix = " ",
        modes = { "n", "i", "c", "x", "o", "t" },
        show_plug = false, -- do not show mappings with "<Plug>"
        lhs_filter = function(lhs)
          return not lhs:find("Þ")
        end, -- remove which-key mappings
      },
      highlights = {
        prompt_prefix = " ",
        layout_config = {
          horizontal = { preview_width = { 0.7, min = 30 } },
        },
      },
      lsp_workspace_symbols = {
        prompt_prefix = "󰒕 ",
        prompt_title = "Functions",
			-- stylua: ignore
			ignore_symbols = { "boolean", "number", "string", "variable", "array", "object", "constant", "package" },
        fname_width = 12,
      },
      buffers = {
        prompt_prefix = "󰽙 ",
        ignore_current_buffer = false,
        sort_mru = true,
        initial_mode = "normal",
        mappings = { n = { ["<D-w>"] = "delete_buffer" } },
        previewer = false,
        layout_config = {
          horizontal = { anchor = "W", width = 0.5, height = 0.5 },
        },
      },
      colorscheme = {
        enable_preview = true,
        prompt_prefix = " ",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            height = 0.4,
            width = 0.3,
            anchor = "SE",
            preview_width = 1, -- needs preview for live preview of the theme
          },
        },
      },
    },
  }

  return template
end

local function register_telescope_keymaps()
  --local keymapcontroller = get_obj("dev.controller.keymapcontroller", "keymapcontroller")
  local keymapcontroller = get_obj("framework.controller.keymapcontroller", "keymapcontroller")

  local keymaps = fetch_telescope_mappings()
  local total_keymaps = #keymaps
  local default_opts = { noremap = true, silent = true, desc = nil }

  for i = 1, total_keymaps do
    --wrap_async_function(function()
    local keymap = keymaps[i]
    local opts = default_opts
    opts.desc = keymap[3]
    keymapcontroller:register_keymap("n", keymap[1], keymap[2], opts)
    --end)()
  end
end

function TelescopeController:load_extension(extension)
  _load_extension(extension)
end

function TelescopeController:setup()
  local telescope = get_module("telescope", "telescope")
  local template = generate_template()

  telescope.setup(template)
  --load_telescope_extensions()
  _load_extension("fzf")
  register_telescope_keymaps()
  telescope_path_autocmd()
end

return TelescopeController
