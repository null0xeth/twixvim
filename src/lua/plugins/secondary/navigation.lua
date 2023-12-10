local function get_clients(opts)
  local ret = {} ---@type lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ---@param client lsp.Client
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

local function on_rename(from, to)
  local clients = get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      ---@diagnostic disable-next-line: invisible
      local resp = client.request_sync("workspace/willRenameFiles", {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000, 0)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end
end

local spec = {
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    cmd = { "NvimTreeToggle" },
    init = function()
      local keymapcontroller = require("framework.controller.keymapcontroller"):new()
      keymapcontroller:register_keymap("n", "<c-n>", "<cmd>NvimTreeToggle<CR>", { silent = true })
      keymapcontroller:register_keymap("n", "<Space>n", "<cmd>NvimTreeFocus<CR>", { silent = true })
    end,
    config = function()
      local navigationcontroller = require("framework.controller.navigationcontroller"):new()
      navigationcontroller:setup()
    end,
  },
  -- file explorer
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   branch = "v3.x",
  --   cmd = "Neotree",
  --   keys = {
  --     {
  --       "<leader>nr",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, dir = Util.root() })
  --       end,
  --       desc = "Explorer NeoTree (root dir)",
  --     },
  --     {
  --       "<leader>nc",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
  --       end,
  --       desc = "Explorer NeoTree (cwd)",
  --     },
  --     { "<c-n>", "<leader>nr", desc = "Explorer NeoTree (root dir)", remap = true },
  --     { "<c-.>", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
  --     {
  --       "<leader>ng",
  --       function()
  --         require("neo-tree.command").execute({ source = "git_status", toggle = true })
  --       end,
  --       desc = "Git explorer",
  --     },
  --     {
  --       "<leader>nb",
  --       function()
  --         require("neo-tree.command").execute({ source = "buffers", toggle = true })
  --       end,
  --       desc = "Buffer explorer",
  --     },
  --   },
  --   deactivate = function()
  --     vim.cmd([[Neotree close]])
  --   end,
  --   init = function()
  --     if vim.fn.argc(-1) == 1 then
  --       local stat = vim.loop.fs_stat(vim.fn.argv(0))
  --       if stat and stat.type == "directory" then
  --         require("neo-tree")
  --       end
  --     end
  --   end,
  --   opts = {
  --     sources = { "filesystem", "buffers", "git_status", "document_symbols" },
  --     open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
  --     filesystem = {
  --       bind_to_cwd = false,
  --       follow_current_file = { enabled = true },
  --       use_libuv_file_watcher = true,
  --     },
  --     window = {
  --       mappings = {
  --         ["<space>"] = "none",
  --       },
  --     },
  --     default_component_configs = {
  --       indent = {
  --         with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
  --         expander_collapsed = "",
  --         expander_expanded = "",
  --         expander_highlight = "NeoTreeExpander",
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     local function on_move(data)
  --       on_rename(data.source, data.destination)
  --     end

  --     local events = require("neo-tree.events")
  --     opts.event_handlers = opts.event_handlers or {}
  --     vim.list_extend(opts.event_handlers, {
  --       { event = events.FILE_MOVED, handler = on_move },
  --       { event = events.FILE_RENAMED, handler = on_move },
  --     })
  --     require("neo-tree").setup(opts)
  --     vim.api.nvim_create_autocmd("TermClose", {
  --       pattern = "*lazygit",
  --       callback = function()
  --         if package.loaded["neo-tree.sources.git_status"] then
  --           require("neo-tree.sources.git_status").refresh()
  --         end
  --       end,
  --     })
  --   end,
  -- },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      keymaps = {
        ["?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        [";v"] = "actions.select_vsplit",
        [";h"] = "actions.select_split",
        [";t"] = "actions.select_tab",
        [";p"] = "actions.preview",
        ["q"] = "actions.close",
        [";r"] = "actions.refresh",
        [".."] = "actions.parent",
        [";o"] = "actions.open_cwd",
        ["cd"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
    },
    keys = {
      { "<leader>mno", "<cmd>Oil<CR>", desc = "Browse parent directory (Oil)" },
      { "<leader>mnf", "<cmd>Oil --float <CR>", desc = "[FLOAT]: Browse parent directory (Oil)" },
    },
  },
  {
    "toppair/reach.nvim",
    enabled = false,
    cmd = { "ReachOpen" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>mrb", "<cmd>ReachOpen buffers<cr>", desc = "Open buffers" },
      { "<leader>mrt", "<cmd>ReachOpen tabpages<cr>", desc = "Open tabpages" },
      { "<leader>mrc", "<cmd>ReachOpen colorschemes<cr>", desc = "Open colorschemes" },
      { "<leader>mrm", "<cmd>ReachOpen marks<cr>", desc = "Open marks" },
    },
    config = function()
      require("reach").setup({
        notifications = true,
      })
    end,
  },
}

return spec
