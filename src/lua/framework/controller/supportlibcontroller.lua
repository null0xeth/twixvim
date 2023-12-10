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

---@class SupportLibController
local SupportLibController = {}
SupportLibController.__index = SupportLibController

function SupportLibController:new()
  local obj = {}
  setmetatable(obj, self)
  return obj
end

local function get_filters()
  local routes = {
    -- redirect to popup
    { filter = { event = "msg_show", min_height = 12 }, view = "popup" },
    { filter = { event = "notify", min_height = 12 }, view = "popup" },

    -- write/deletion messages
    { filter = { event = "msg_show", find = "%d+B written$" }, skip = true },
    { filter = { event = "msg_show", find = "%d+L, %d+B$" }, skip = true },
    { filter = { event = "msg_show", find = "%-%-No lines in buffer%-%-" }, skip = "true" },

    -- unneeded info on search patterns
    { filter = { event = "msg_show", find = "^[/?]." }, skip = true },
    { filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

    -- Word added to spellfile via
    { filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },

    -- Diagnostics
    {
      filter = { event = "msg_show", find = "No more valid diagnostics to move to" },
      view = "mini",
    },

    -- :make
    { filter = { event = "msg_show", find = "^:!make" }, skip = true },
    { filter = { event = "msg_show", find = "^%(%d+ of %d+%):" }, skip = true },

    -----------------------------------------------------------------------------
    { -- nvim-early-retirement
      filter = {
        event = "notify",
        cond = function(msg)
          return msg.opts and msg.opts.title == "Auto-Closing Buffer"
        end,
      },
      view = "mini",
    },

    -- nvim-treesitter
    { filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
    { filter = { event = "notify", find = "All parsers are up%-to%-date" }, view = "mini" },

    -- sg.nvim (sourcegraph)
    { filter = { event = "msg_show", find = "^%[sg%]" }, view = "mini" },
    { filter = { event = "notify", find = "^%[sg%]" }, view = "mini" },

    -- Mason
    { filter = { event = "notify", find = "%[mason%-tool%-installer%]" }, view = "mini" },
    {
      filter = {
        event = "notify",
        cond = function(msg)
          return msg.opts and msg.opts.title and msg.opts.title:find("mason.*.nvim")
        end,
      },
      view = "mini",
    },

    -- DAP
    { filter = { event = "notify", find = "^Session terminated$" }, view = "mini" },
  }

  return routes
end

local function noice_generate_opts_template()
  local opts = {
    cmdline = {
      enabled = true, -- enables the Noice cmdline UI
      view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
      opts = {}, -- global options for the cmdline. See section on views
      ---@type table<string, CmdlineFormat>
      format = {
        -- view: (default is cmdline view)
        -- opts: any options passed to the view
        -- icon_hl_group: optional hl_group for the icon
        -- title: set to anything or empty string to hide
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
        lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
        input = {}, -- Used by input()
        -- lua = false, -- to disable a format, set to `false`
      },
    },
    messages = {
      -- NOTE: If you enable messages, then the cmdline is enabled automatically.
      -- This is a current Neovim limitation.
      enabled = true, -- enables the Noice messages UI
      view = "notify", -- default view for messages
      view_error = "notify", -- view for errors
      view_warn = "notify", -- view for warnings
      view_history = "messages", -- view for :messages
      view_search = false, -- view for search count messages. Set to `false` to disable
    },
    popupmenu = {
      enabled = true, -- enables the Noice popupmenu UI
      ---@type 'nui'|'cmp'
      backend = "cmp", -- backend to use to show regular cmdline completions
      ---@type NoicePopupmenuItemKind|false
      -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
      kind_icons = {}, -- set to `false` to disable icons
    },
    -- default options for require('noice').redirect
    -- see the section on Command Redirection
    ---@type NoiceRouteConfig
    redirect = {
      view = "popup",
      filter = { event = "msg_show" },
    },
    -- You can add any custom commands below that will be available with `:Noice command`
    ---@type table<string, NoiceCommand>
    commands = {
      history = {
        -- options for the message history that you get with `:Noice`
        view = "split",
        filter_opts = { reverse = true },
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
      },
      -- :Noice last
      last = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
        filter_opts = { count = 1 },
      },
      -- :Noice errors
      errors = {
        -- options for the message history that you get with `:Noice`
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { error = true },
        filter_opts = { reverse = true },
      },
    },
    notify = {
      -- Noice can be used as `vim.notify` so you can route any notification like other messages
      -- Notification messages have their level and other properties set.
      -- event is always "notify" and kind can be any log level as a string
      -- The default routes will forward notifications to nvim-notify
      -- Benefit of using Noice for this is the routing and consistent history view
      enabled = true,
      view = "notify",
    },
    lsp = {
      progress = {
        enabled = true,
        -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
        -- See the section on formatting for more details on how to customize.
        --- @type NoiceFormat|string
        format = "lsp_progress",
        --- @type NoiceFormat|string
        format_done = "lsp_progress_done",
        throttle = 1000 / 30, -- frequency to update lsp progress message
        view = "mini",
      },
      override = {
        -- override the default lsp markdown formatter with Noice
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        -- override the lsp markdown formatter with Noice
        ["vim.lsp.util.stylize_markdown"] = true,
        -- override cmp documentation with Noice (needs the other options to work)
        ["cmp.entry.get_documentation"] = true,
      },
      hover = {
        enabled = true,
        silent = false, -- set to true to not show a message if hover is not available
        view = nil, -- when nil, use defaults from documentation
        ---@type NoiceViewOptions
        opts = {}, -- merged with defaults from documentation
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
          luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
          throttle = 50, -- Debounce lsp signature help request by 50ms
        },
        view = nil, -- when nil, use defaults from documentation
        ---@type NoiceViewOptions
        opts = {}, -- merged with defaults from documentation
      },
      message = {
        -- Messages shown by lsp servers
        enabled = true,
        view = "notify",
        opts = {},
      },
      -- defaults for hover and signature help
      documentation = {
        view = "hover",
        ---@type NoiceViewOptions
        opts = {
          lang = "markdown",
          replace = true,
          render = "plain",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 },
        },
      },
    },
    markdown = {
      hover = {
        ["|(%S-)|"] = vim.cmd.help, -- vim help links
        ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
      },
      highlights = {
        ["|%S-|"] = "@text.reference",
        ["@%S+"] = "@parameter",
        ["^%s*(Parameters:)"] = "@text.title",
        ["^%s*(Return:)"] = "@text.title",
        ["^%s*(See also:)"] = "@text.title",
        ["{%S-}"] = "@parameter",
      },
    },
    health = {
      checker = true, -- Disable if you don't want health checks to run
    },
    smart_move = {
      -- noice tries to move out of the way of existing floating windows.
      enabled = true, -- you can disable this behaviour here
      -- add any filetypes here, that shouldn't trigger smart move.
      excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
    },
    ---@type NoicePresets
    presets = {
      -- you can enable a preset by setting it to true, or a table that will override the preset config
      -- you can also add custom presets that you can enable/disable with enabled=true
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = false, -- position the cmdline and popupmenu together
      long_message_to_split = false, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
      cmdline_output_to_split = false,
    },
    throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
    ---@type NoiceConfigViews
    views = {
      cmdline_popup = {
        border = { style = "rounded" },
        position = {
          row = 5,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
      mini = {
        timeout = 3000,
        zindex = 10,
      },
      hover = {
        border = { style = "rounded" },
        size = { max_width = 80 },
        win_options = { scrolloff = 4 },
      },
      popup = {
        border = { style = "rounded" },
        size = { width = 90, height = "auto" },
        win_options = { scrolloff = 4 },
      },
      -- popupmenu = {
      --   relative = "editor",
      --   position = {
      --     row = 8,
      --     col = "50%",
      --   },
      --   size = {
      --     width = 60,
      --     height = "auto",
      --   },
      --   border = {
      --     padding = { 0, 1 },
      --   },
      --   win_options = {
      --     winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      --   },
      -- },
    }, ---@see section on views
    routes = get_filters(),
    -- ---@type NoiceRouteConfig[]
    -- routes = {
    --   {
    --     filter = {
    --       event = "msg_show",
    --       kind = "search_count",
    --     },
    --     opts = { skip = true },
    --   },
    -- },
    -- { -- hide all msgs with kind [""]
    --   filter = {
    --     event = "msg_show",
    --     kind = "",
    --   },
    --   opts = { skip = true },
    -- },
    -- {
    --   filter = {
    --     event = "msg_show",
    --     kind = "",
    --     find = "written",
    --   },
    --   opts = { skip = true },
    -- },
    -- {
    --   view = "split",
    --   filter = { event = "msg_show", min_height = 20 },
    -- },
    --}, --- @see section on routes
    ---@type table<string, NoiceFilter>
    status = {}, --- @see section on statusline components
    ---@type NoiceFormatOptions
    format = {}, --- @see section on formatting
  }
  return opts
end

function SupportLibController:noice_setup()
  local noice = require("noice")
  local opts = noice_generate_opts_template()
  noice.setup(opts)

  local notif = require("notify")
  vim.notify = notif
  notif.setup({
    render = "wrapped-compact",
    top_down = true,
    max_width = 80,
    minimum_width = 15,
    level = vim.log.levels.TRACE,
    timeout = 6000,
    stages = "slide",
    --background_color = "Normal",
    -- fpd = 30,
    -- level = 2,
    -- minimum_width = 50,
    -- render = "default",
    -- stages = "slide",
  })
end

return SupportLibController
