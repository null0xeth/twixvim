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

local CompletionController = {}
CompletionController.__index = CompletionController

function CompletionController:new()
  local obj = {}
  setmetatable(obj, CompletionController)
  return obj
end

local function fetch_cmp_sources()
  return {
    { name = "path", priority_weight = 110 },
    { name = "crates", priority_weight = 110 },
    { name = "dotenv", priority_weight = 90, max_item_count = 5 },
    {
      name = "nvim_lsp",
      max_item_count = 20,
      priority_weight = 100,
      entry_filter = function(entry, ctx)
        -- fifteen = snippet, 23 = event
        if entry:get_kind() == 23 or entry:get_kind() == 15 then
          return false
        end
        return true
      end,
    },
    { name = "nvim_lua", priority_weight = 90 },
    { name = "luasnip", priority_weight = 80 },
    {
      name = "buffer",
      max_item_count = 5,
      priority_weight = 50,
      entry_filter = function(entry)
        return not entry.exact
      end,
    },
  }
end

local function fetch_cmp_mappings()
  local cmp = get_module("cmp", "cmp")

  local mappings = {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
    ["<C-Tab>"] = cmp.mapping(function(fallback)
      local luasnip = get_module("luasnip", "luasnip")
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif luasnip.jumpable() then
        luasnip.jump_next()
      else
        fallback()
      end
    end, {
      "i",
      "c",
    }),
    ["`"] = cmp.mapping(function(fallback)
      local luasnip = get_module("luasnip", "luasnip")
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif luasnip.jumpable(true) then
        luasnip.jump_prev()
      else
        fallback()
      end
    end, {
      "i",
      "c",
    }),
  }
  return mappings
end

local function fetch_cmp_formatting()
  local cmp = get_module("cmp", "cmp")
  return {
    fields = {
      cmp.ItemField.Kind,
      cmp.ItemField.Abbr,
      cmp.ItemField.Menu,
    },
    format = function(entry, vim_item)
      local kind = require("lspkind").cmp_format({
        mode = "symbol_text",
        preset = "codicons",
        maxwidth = 60,
        menu = {
          buffer = "[BUF]",
          dotenv = "[ENV]",
          nvim_lsp = "[LSP]",
          nvim_lua = "[NLUA]",
          luasnip = "[SNIP]",
          crates = "[CRATE]",
          cmdline_history = "[HIST]",
          cmdline = "[CMD]",
          path = "[PATH]",
          dap = "[DAP]",
        },
      })(entry, vim_item)

      local strings = vim.split(vim_item.kind, "%s+", { trimempty = true })
      kind.kind = string.format(" [%s] %s ", strings[1], strings[2])
      return kind
    end,
  }
end

local function fetch_cmp_sorting()
  local compare = get_module("cmp.config.compare", "compare")
  local types = require("cmp.types")

  local priority_map = {
    [types.lsp.CompletionItemKind.EnumMember] = 1,
    [types.lsp.CompletionItemKind.Variable] = 2,
    [types.lsp.CompletionItemKind.Text] = 100,
  }

  local kind = function(entry1, entry2)
    local kind1 = entry1:get_kind()
    local kind2 = entry2:get_kind()
    kind1 = priority_map[kind1] or kind1
    kind2 = priority_map[kind2] or kind2
    if kind1 ~= kind2 then
      if kind1 == types.lsp.CompletionItemKind.Snippet then
        return true
      end
      if kind2 == types.lsp.CompletionItemKind.Snippet then
        return false
      end
      local diff = kind1 - kind2
      if diff < 0 then
        return true
      elseif diff > 0 then
        return false
      end
    end
  end

  return {
    priority_weight = 100,
    comparators = {
      compare.offset,
      compare.exact,
      compare.score,

      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find("^_+")
        local _, entry2_under = entry2.completion_item.label:find("^_+")
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end,

      kind,
      compare.sort_text,
      compare.length,
      compare.order,
    },
  }
end

local function fetch_cmp_window()
  return {
    completion = {
      winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:Search",
      col_offset = 0,
      side_padding = 0,
      border = "rounded",
      scrollbar = nil,
    },

    documentation = {
      border = "rounded",
      winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:Search",
      zindex = 1001,
    },
  }
end

local function fetch_cmp_snippet()
  local luasnip = get_module("luasnip", "luasnip")
  local snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  }

  return snippet
end

local function generate_cmp_template()
  local fetched_sources = fetch_cmp_sources()
  local cmp = get_module("cmp", "cmp")
  local template = {
    sources = cmp.config.sources(fetched_sources),
    window = fetch_cmp_window(),
    view = { entries = { name = "custom", selection_order = "near_cursor" } }, --is new
    formatting = fetch_cmp_formatting(),
    snippet = fetch_cmp_snippet(),
    mapping = fetch_cmp_mappings(),
    sorting = fetch_cmp_sorting(),
    -- leave as template
    experimental = {
      native_menu = false,
      ghost_text = false,
      -- ghost_text = {
      --   hl_group = "CmpGhostText",
      -- },
    },
  }

  return template
end

local function generate_cmp_cmdline_template(identifier, opts)
  local cmp = get_module("cmp", "cmp")
  cmp.setup.cmdline(identifier, opts)
end

local function generate_cmp_filetype_template(filetype, opts)
  local cmp = get_module("cmp", "cmp")
  cmp.setup.filetype(filetype, opts)
end

local function setup_cmp_autopairs()
  local cmp = get_module("cmp", "cmp")
  local cmp_autopairs = get_module("nvim-autopairs.completion.cmp", "autopairs")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
end

local function setup_crates_autocmds()
  local autocmdcontroller = get_obj("framework.controller.autocmdcontroller", "autocmdcontroller")
  local cmp = get_module("cmp", "cmp")
  autocmdcontroller:add_autocmd({
    event = "BufRead",
    group = autocmdcontroller:add_augroup("CmpSourceCargo", { clear = true }),
    pattern = "Cargo.toml",
    command_or_callback = function()
      cmp.setup.buffer({ sources = { { name = "crates" } } })
    end,
  })
end

local function register_crates_keys()
  local crates = get_module("crates", "crates")
  local wk = get_module("which-key", "whichkey")
  wk.register({
    ["<leader>lrc"] = {
      name = "Crates",
      ["t"] = { crates.toggle, "Toggle" },
      ["r"] = { crates.reload, "Reload" },

      ["v"] = { crates.show_versions_popup, "Versions popup" },
      ["f"] = { crates.show_features_popup, "Features popup" },
      ["d"] = { crates.show_dependencies_popup, "Dependencies popup" },

      ["u"] = { crates.update_crate, "Update crate" },
      ["U"] = { crates.upgrade_crate, "Upgrade crate" },
      ["a"] = { crates.update_all_crates, "Update all crates" },
      ["A"] = { crates.upgrade_all_crates, "Upgrade all crates" },

      ["H"] = { crates.open_homepage, "Open homepage" },
      ["R"] = { crates.open_repository, "Open repository" },
      ["D"] = { crates.open_documentation, "Open documentation" },
      ["C"] = { crates.open_crates_io, "Open crates.io" },
    },
  })

  wk.register({
    ["<leader>c"] = {
      name = "Crates",
      ["u"] = { ":lua require('crates').update_crates()<cr>", "Update selected crates" },
      ["U"] = { ":lua require('crates').upgrade_crates()<cr>", "Upgrade selected crates" },
    },
  }, {
    mode = "v",
  })
end

function CompletionController:initialize_cmp()
  vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
  local cmp = get_module("cmp", "cmp")
  local cmp_opts = generate_cmp_template()

  cmp.setup(cmp_opts)

  --generate_cmp_cmdline_template({ "/", "?" }, {
  generate_cmp_cmdline_template({ "/" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
    formatting = {
      fields = {
        cmp.ItemField.Abbr,
      },
    },
    -- {
    --   { name = "cmdline_history" },
    -- },
  })

  generate_cmp_cmdline_template(":", {
    mapping = cmp.mapping.preset.cmdline(),
    enabled = function()
      local cmd = vim.fn.getcmdline()
      if cmd:find("^IncRename") or cmd:find("^%d+$") or cmd:find("^s ") then
        cmp.close()
        return false
      end
      return true
    end,
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }), --{
    formatting = {
      fields = {
        cmp.ItemField.Abbr,
      },
    },
    --   { name = "buffer" },
    -- }, {
    --   { name = "cmdline_history" },
    --}),
    -- }, {
    --   { name = "cmdline" },
    --}),
  })

  generate_cmp_filetype_template("gitcommit", {
    sources = cmp.config.sources({
      --{ name = "git" },
      { name = "buffer" },
      { name = "luasnip" },
    }),
  })

  setup_cmp_autopairs()
end

function CompletionController:initialize_crates()
  local crates = get_module("crates", "crates")
  crates.setup({
    popup = {
      border = "rounded",
      show_version_date = true,
    },
    src = {
      cmp = {
        enabled = true,
      },
    },
  })

  register_crates_keys()
  setup_crates_autocmds()
end

return CompletionController
