--vim.opt.listchars:append({ tab = "  ", extends = "", precedes = "" })

local options = {
  opt = {
    breakindent = true, -- wrap indent to match  line start
    clipboard = "unnamedplus", -- connection to the system clipboard
    cmdheight = 0, -- hide command line unless needed
    conceallevel = 2,
    confirm = false,
    completeopt = { "menu", "menuone", "noselect" }, -- Options for insert mode completion
    copyindent = true, -- copy the previous indentation on autoindenting
    cursorline = true, -- highlight the text line of the cursor
    expandtab = true, -- enable the use of space in tab
    fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", eob = " ", diff = "╱" }, -- diff = "╱"
    foldenable = false, -- enable fold for nvim-ufo
    foldcolumn = "auto",
    foldlevel = 99, -- set high foldlevel for nvim-ufo
    foldlevelstart = 99, -- start with all code unfolded
    history = 100, -- number of commands to remember in a history table
    hidden = true,
    ignorecase = true, -- case insensitive searching
    infercase = true, -- infer cases in keyword completion
    joinspaces = false,
    laststatus = 3, -- global statusline
    linebreak = true, -- wrap lines at 'breakat'
    list = false,
    mouse = "a", -- enable mouse support
    mousemodel = "extend",
    number = true, -- show numberline
    preserveindent = true, -- preserve indent structure as much as possible
    pumheight = 10, -- height of the pop up menu
    relativenumber = false, -- show relative numberline
    report = 9001,
    scrollback = 100000,
    scrolloff = 3, --scrolloff = 8
    sidescrolloff = 8,
    shell = "/run/current-system/sw/bin/bash",
    shiftwidth = 2, -- number of space inserted for indentation
    showbreak = "⮡   ",
    showcmd = false,
    showmode = false, -- disable showing modes in command line
    --showtabline = 2, -- always display tabline
    signcolumn = "auto:2", -- always show the sign column
    smartcase = true, -- case sensitive searching
    smoothscroll = false,
    splitbelow = true, -- splitting a new window below the current one
    splitright = true, -- splitting a new window at the right of the current one
    splitkeep = "screen",
    swapfile = false,
    tabstop = 2, -- number of space in a tab
    termguicolors = true, -- enable 24-bit RGB color in the TUI
    textwidth = 0,
    timeoutlen = 500, -- shorten key timeout length a little bit for which-key
    undofile = true, -- enable persistent undo
    undolevels = 1000,
    updatetime = 300, -- length of time to wait before triggering the plugin
    virtualedit = "block", -- allow going past end of line in visual block mode
    wrap = false, -- disable wrapping of lines longer than the width of window
    wrapmargin = 0,
    writebackup = false, -- disable making a backup before overwriting a file
  },
  g = {
    mapleader = " ", -- set leader key
    maplocalleader = ",", -- set default local leader key
    loaded_python3_provider = 0,
    loaded_perl_provider = 0,
    loaded_ruby_provider = 0,
    loaded_node_provider = 0,
  },
}

for scope, table in pairs(options) do
  local option_type = vim[scope]
  for setting, value in pairs(table) do
    option_type[setting] = value
  end
end

vim.opt.shortmess:append("sSI")
vim.opt.iskeyword:append("-")
vim.keymap.set("", "<Space>", "<Nop>", { silent = true })
