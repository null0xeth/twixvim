local function get_clients(opts)
  local ret = {} ---@type lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_clients(opts)
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
