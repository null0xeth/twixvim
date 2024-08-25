local spec = {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    init = function()
      vim.g.neo_tree_remove_legacy_commands = true
    end,
    keys = {
      {
        "<leader>nt",
        "<cmd>Neotree toggle<cr>",
        desc = "General: [t]oggle the [f]olders explorer",
      },
      {
        "<leader>ng",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "General: [t]oggle the [g]it status explorer",
      },
      {
        "<leader>ns",
        function()
          require("neo-tree.command").execute({ source = "document_symbols", toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "General: [t]oggle the [s]ymbols explorer",
      },
      { "<c-n>", "<leader>nt", desc = "Explorer NeoTree (root dir)", remap = true },
    },
    cmd = "Neotree",

    config = function()
      require("neo-tree").setup({
        sources = { "filesystem", "buffers", "git_status" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline", "edgy" }, -- and edgy?
        auto_clean_after_session_restore = true,
        close_if_last_window = true,
        popup_border_style = "rounded",
        resize_timer_interval = 67,
        use_default_mappings = false,

        default_source = "filesystem", -- you can choose a specific source `last` here which indicates the last used source
        enable_diagnostics = false,
        enable_git_status = true,
        enable_modified_markers = true, -- Show markers for files with unsaved changes.
        enable_opened_markers = true, -- Enable tracking of opened files. Required for `components.name.highlight_opened_files`
        enable_refresh_on_write = false, -- Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.

        -- source_selector provides clickable tabs to switch between sources.
        -- source selector component:
        source_selector = {
          winbar = false, -- toggle to show selector on winbar
          statusline = false, -- toggle to show selector on statusline
          show_scrolled_off_parent_node = false, -- boolean
          sources = { -- table
            {
              source = "filesystem", -- string
              display_name = " 󰉓 Files ", -- string | nil
            },
            { source = "document_symbols", display_name = "  SYMBOLS " },
            {
              source = "buffers", -- string
              display_name = " 󰈚 Buffers ", -- string | nil
            },
            {
              source = "git_status", -- string
              display_name = " 󰊢 Git ", -- string | nil
            },
          },
          content_layout = "center", -- string
          separator = "",
          separator_active = { left = "▎", right = "" },
          show_separator_on_edge = false,
        },
        event_handlers = {
          {
            event = "file_opened",
            handler = function()
              require("neo-tree.command").execute({ action = "close" })
            end,
          },
          {
            event = "file_renamed",
            handler = function(args)
              for _, client in pairs(vim.lsp.get_clients()) do
                if client.supports_method("workspace/willRenameFiles") then
                  local resp = client.request_sync("workspace/willRenameFiles", {
                    files = {
                      {
                        oldUri = vim.uri_from_fname(args.source),
                        newUri = vim.uri_from_fname(args.destination),
                      },
                    },
                  }, 1000, 0)

                  if resp and resp.result ~= nil then
                    vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
                  end
                end
              end
            end,
          },
          {
            event = "file_moved",
            handler = function(args)
              for _, client in pairs(vim.lsp.get_clients()) do
                if client.supports_method("workspace/willRenameFiles") then
                  local resp = client.request_sync("workspace/willRenameFiles", {
                    files = {
                      {
                        oldUri = vim.uri_from_fname(args.source),
                        newUri = vim.uri_from_fname(args.destination),
                      },
                    },
                  }, 1000, 0)

                  if resp and resp.result ~= nil then
                    vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
                  end
                end
              end
            end,
          },
        },
        default_component_configs = {
          container = {
            enable_character_fade = true,
            width = "100%",
            right_padding = 1,
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            folder_empty_open = "",
            default = "",
            highlight = "NeoTreeFileIcon",
          },
          indent = {
            padding = 0,
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          name = {
            use_git_status_colors = false,
          },
          modified = {
            symbol = "[+] ",
            highlight = "NeoTreeModified",
          },
          git_status = {
            symbols = {
              -- Change type
              added = "✚", -- NOTE: you can set any of these to an empty string to not show them
              deleted = "✖",
              modified = "",
              renamed = "󰁕",
              -- Status type
              untracked = "",
              ignored = "",
              unstaged = "󰄱",
              staged = "",
              conflict = "",
            },
            align = "right",
          },
          -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
          file_size = {
            enabled = false,
            required_width = 64, -- min width of window required to show this column
          },
          type = {
            enabled = false,
            required_width = 110, -- min width of window required to show this column
          },
          last_modified = {
            enabled = false,
            required_width = 88, -- min width of window required to show this column
          },
          created = {
            enabled = false,
            required_width = 120, -- min width of window required to show this column
          },
          symlink_target = {
            enabled = false,
          },
        },
        renderers = {
          directory = {
            { "indent" },
            { "icon" },
            { "current_filter" },
            {
              "container",
              content = {
                { "name", zindex = 10 },
                { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
                { "clipboard", zindex = 10 },
                { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
                { "file_size", zindex = 10, align = "right" },
                { "type", zindex = 10, align = "right" },
                { "last_modified", zindex = 10, align = "right" },
                { "created", zindex = 10, align = "right" },
              },
            },
          },
          file = {
            { "indent" },
            { "icon" },
            {
              "container",
              content = {
                { "name", zindex = 10 },
                { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
                { "clipboard", zindex = 10 },
                { "modified", zindex = 20, align = "right" },
                { "git_status", zindex = 10, align = "right" },
                { "file_size", zindex = 10, align = "right" },
                { "type", zindex = 10, align = "right" },
                { "last_modified", zindex = 10, align = "right" },
                { "created", zindex = 10, align = "right" },
              },
            },
          },
        },
        window = {
          position = "left",
          width = 40,
          auto_expand_width = false,
          --width = require("wuelnerdotexe.plugin.util").get_sidebar_width(),
          insert_as = "sibling",
          mappings = {
            -- -- Transfer.nvim mapppings
            -- uu = {
            --   function(state)
            --     vim.cmd("TransferUpload " .. state.tree:get_node().path)
            --   end,
            --   desc = "upload file or directory",
            --   nowait = true,
            -- },
            -- -- download (sync files)
            -- ud = {
            --   function(state)
            --     vim.cmd("TransferDownload" .. state.tree:get_node().path)
            --   end,
            --   desc = "download file or directory",
            --   nowait = true,
            -- },
            -- -- diff directory with remote
            -- uf = {
            --   function(state)
            --     local node = state.tree:get_node()
            --     local context_dir = node.path
            --     if node.type ~= "directory" then
            --       -- if not a directory
            --       -- one level up
            --       context_dir = context_dir:gsub("/[^/]*$", "")
            --     end
            --     vim.cmd("TransferDirDiff " .. context_dir)
            --     vim.cmd("Neotree close")
            --   end,
            --   desc = "diff with remote",
            -- },
            -- End of Transfer.nvim mappings
            ["<CR>"] = "open",
            ["<2-LeftMouse>"] = "open",
            ["<localleader>pt"] = { "toggle_preview", config = { use_float = true } },
            ["<C-s>"] = "open_split",
            ["<C-v>"] = "open_vsplit",
            ["<C-t>"] = "open_tabnew",
            ["<F5>"] = "refresh",
            ["a"] = { "add", config = { show_path = "relative" } },
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = { "copy", config = { show_path = "relative" } },
            ["m"] = { "move", config = { show_path = "relative" } },
            ["q"] = "close_window",
            ["?"] = "show_help",
            ["gb"] = require("lazy.core.config").spec.plugins["edgy.nvim"] == nil and "next_source" or "noop",
            ["<S-PageDown>"] = require("lazy.core.config").spec.plugins["edgy.nvim"] == nil and "next_source" or "noop",
            ["gB"] = require("lazy.core.config").spec.plugins["edgy.nvim"] == nil and "prev_source" or "noop",
            ["<S-PageUp>"] = require("lazy.core.config").spec.plugins["edgy.nvim"] == nil and "prev_source" or "noop",
          },
        },
        filesystem = {
          window = {
            mappings = {
              ["/"] = "fuzzy_finder",
              ["<C-f>"] = "filter_on_submit",
              ["<Esc>"] = "clear_filter",
              ["<"] = "navigate_up",
              [">"] = "set_root",
              ["[g"] = "prev_git_modified",
              ["]g"] = "next_git_modified",
              ["K"] = "show_file_details",
            },
          },
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
            never_show = { ".git", ".svn", ".hg", "CSV", ".DS_Store", "thumbs.db" },
          },
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "open_current",
          use_libloop_file_watcher = true,
          bind_to_cwd = true,
        },
        git_status = {
          window = {
            mappings = {
              ["gA"] = "git_add_all",
              ["gu"] = "git_unstage_file",
              ["gs"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["K"] = "show_file_details",
            },
          },
        },
        document_symbols = {
          follow_cursor = true,
          client_filters = "all",
          window = {
            mappings = {
              ["<CR>"] = "toggle_node",
              ["<2-LeftMouse>"] = "toggle_node",
              ["a"] = "noop",
              ["d"] = "noop",
              ["r"] = "noop",
              ["y"] = "noop",
              ["x"] = "noop",
              ["p"] = "noop",
              ["c"] = "noop",
              ["m"] = "noop",
              ["o"] = "jump_to_symbol",
              ["/"] = "filter",
              ["<C-f>"] = "filter_on_submit",
            },
          },
          buffers = {
            bind_to_cwd = true,
            follow_current_file = {
              enabled = true, -- This will find and focus the file in the active buffer every time
              --              -- the current file is changed while the tree is open.
              leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
            },
            group_empty_dirs = true, -- when true, empty directories will be grouped together
            show_unloaded = false, -- When working with sessions, for example, restored but unfocused buffers
            -- are mark as "unloaded". Turn this on to view these unloaded buffer.
            terminals_first = false, -- when true, terminals will be listed before file buffers
            window = {
              mappings = {
                ["<bs>"] = "navigate_up",
                ["."] = "set_root",
                ["bd"] = "buffer_delete",
                ["i"] = "show_file_details",
                ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
                ["oc"] = { "order_by_created", nowait = false },
                ["od"] = { "order_by_diagnostics", nowait = false },
                ["om"] = { "order_by_modified", nowait = false },
                ["on"] = { "order_by_name", nowait = false },
                ["os"] = { "order_by_size", nowait = false },
                ["ot"] = { "order_by_type", nowait = false },
              },
            },
          },
          kinds = {
            Unknown = { icon = "?", hl = "" },
            Root = { icon = "", hl = "NeoTreeRootName" },
            File = { icon = "󰈙", hl = "Tag" },
            Module = { icon = "", hl = "Exception" },
            Namespace = { icon = "󰌗", hl = "Include" },
            Package = { icon = "󰏖", hl = "Label" },
            Class = { icon = "󰌗", hl = "Include" },
            Method = { icon = "", hl = "Function" },
            Property = { icon = "󰆧", hl = "@property" },
            Field = { icon = "", hl = "@field" },
            Constructor = { icon = "", hl = "@constructor" },
            Enum = { icon = "󰒻", hl = "@number" },
            Interface = { icon = "", hl = "Type" },
            Function = { icon = "󰊕", hl = "Function" },
            Variable = { icon = "", hl = "@variable" },
            Constant = { icon = "", hl = "Constant" },
            String = { icon = "󰀬", hl = "String" },
            Number = { icon = "󰎠", hl = "Number" },
            Boolean = { icon = "", hl = "Boolean" },
            Array = { icon = "󰅪", hl = "Type" },
            Object = { icon = "󰅩", hl = "Type" },
            Key = { icon = "󰌋", hl = "" },
            Null = { icon = "", hl = "Constant" },
            EnumMember = { icon = "", hl = "Number" },
            Struct = { icon = "󰌗", hl = "Type" },
            Event = { icon = "", hl = "Constant" },
            Operator = { icon = "󰆕", hl = "Operator" },
            TypeParameter = { icon = "󰊄", hl = "Type" },

            -- ccls
            -- TypeAlias = { icon = ' ', hl = 'Type' },
            -- Parameter = { icon = ' ', hl = '@parameter' },
            -- StaticMethod = { icon = '󰠄 ', hl = 'Function' },
            -- Macro = { icon = ' ', hl = 'Macro' },
          },
          -- kinds = {
          --   File = { icon = "", hl = "@text" },
          --   Module = { icon = "", hl = "@text" },
          --   Namespace = { icon = "", hl = "@namespace" },
          --   Package = { icon = "", hl = "@string" },
          --   Class = { icon = "", hl = "@type" },
          --   Method = { icon = "", hl = "@method" },
          --   Property = { icon = "", hl = "@property" },
          --   Field = { icon = "", hl = "@field" },
          --   Constructor = { icon = " ", hl = "@constructor" },
          --   Enum = { icon = "", hl = "@type" },
          --   Interface = { icon = "", hl = "@type" },
          --   Function = { icon = "", hl = "@function" },
          --   Variable = { icon = "", hl = "@variable" },
          --   Constant = { icon = "", hl = "@constant" },
          --   String = { icon = "", hl = "@string" },
          --   Number = { icon = "", hl = "@number" },
          --   Boolean = { icon = "", hl = "@boolean" },
          --   Array = { icon = "", hl = "@variable" },
          --   Object = { icon = "", hl = "@type" },
          --   Key = { icon = "", hl = "@variable" },
          --   Null = { icon = "ﳠ", hl = "@boolean" },
          --   EnumMember = { icon = "", hl = "@property" },
          --   Struct = { icon = "", hl = "@type" },
          --   Event = { icon = "", hl = "@variable.builtin" },
          --   Operator = { icon = "", hl = "@operator" },
          --   TypeParameter = { icon = "", hl = "@type" },
          -- },
        },
      })
    end,
  },
}

return spec
