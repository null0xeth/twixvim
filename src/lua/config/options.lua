local g = vim.g
local opt = vim.opt

local vim_opt_options = {
  general_options = {
    --formatexpr = 'v:lua.require("conform").formatexpr()',
    ttyfast = true,
    breakindent = true,
    clipboard = vim.env.SSH_TTY and "" or "unnamedplus",
    joinspaces = false,
    scrollback = 100000,
    shell = "/run/current-system/sw/bin/bash",
    timeoutlen = 300,
    title = true,
    history = 400,
    virtualedit = "block",
    whichwrap = "b,h,l",
    wildmode = "longest,full", -- cmdline completion
    wildoptions = "pum",
    report = 9001,
  },
  ui = {
    laststatus = 3,
    confirm = true, -- confirm saving before exiting
    cursorline = true,
    conceallevel = 2, -- hide markup shit
    emoji = false,
    list = false, -- show chars like tabs...
    signcolumn = "no",
    number = true,
    relativenumber = false, -- releativenumber = false
    linebreak = true,
    showbreak = "⮡   ",
    wrap = false,
    scrolloff = 3, --scrolloff = 8
    sidescrolloff = 8,
    textwidth = 0,
    wrapmargin = 0,
    cmdheight = 0, -- cmdheight = 0
    showmode = false,
    showcmd = false,
    --termguicolors = true,
  },
  indentation = {
    autoindent = true,
    smartindent = true,
    expandtab = true,
    shiftround = true, -- round idnentation
    shiftwidth = 2, -- shiftwidth = 2
    softtabstop = 2,
    smartcase = true,
    tabstop = 2, -- tabstop = 2
    startofline = false,
  },
  misc = {
    diffopt = "internal,filler,closeoff,foldcolumn:1,hiddenoff,algorithm:patience,linematch:60",
    updatetime = 300,
    mouse = "a",
    hidden = true,
  },
  splits = {
    splitkeep = "screen",
    splitbelow = true,
    splitright = true,
  },
  undo = {
    undolevels = 1000,
    undodir = vim.fn.stdpath("data") .. "undo",
    undofile = true,
    swapfile = false,
  },
  search = {
    grepformat = "%f:%l:%c:%m", -- if grep fekked remove dis
    grepprg = "rg --vimgrep --smart-case --hidden",
    incsearch = true,
    inccommand = "nosplit",
    ignorecase = true,
    infercase = true,
    hlsearch = true,
    showmatch = true,
    gdefault = true,
  },
  completion_options = {
    completeopt = "menu,menuone,noselect,noinsert",
  },
  fold_options = {
    fillchars = {
      foldopen = "",
      foldclose = "",
      fold = " ",
      foldsep = " ",
      eob = " ",
      diff = "╱",
      horiz = "─",
      horizup = "┴", --	upwards facing horizontal separator
      horizdown = "┬", -- or '-' --	downwards facing horizontal separator
      vert = "│", -- or '|' --	vertical separators |:vsplit|
      vertleft = "┤", -- or '|' --	left facing vertical separator
      vertright = "├", -- or '|' --	right facing vertical separator
      verthoriz = "┼",
    }, -- diff = "╱"
    foldenable = true, -- enable fold for nvim-ufo
    foldcolumn = "auto",
    foldlevel = 99, -- set high foldlevel for nvim-ufo
    foldlevelstart = 99, -- start with all code unfolded
    foldmethod = "expr",
    smoothscroll = true,
    foldexpr = "v:lua.vim.treesitter.foldexpr()",
    foldtext = "v:lua.vim.treesitter.foldtext()",
  },
  pum_options = {
    pumblend = 10,
    pumheight = 10,
  },
  session_options = {
    sessionoptions = { "buffers", "curdir", "tabpages", "winsize" },
  },
}

local vim_g_options = {
  disabled_providers = {
    loaded_python3_provider = 0,
    loaded_perl_provider = 0,
    loaded_ruby_provider = 0,
    loaded_node_provider = 0,
  },
  global = {
    mapleader = " ",
    maplocalleader = ",",
    markdown_recommended_style = 0,
    loaded_netrw = 0,
    loaded_netrwPlugin = 0,
  },
}

vim.filetype.add({
  extension = {
    tf = "terraform",
    tfvars = "terraform-vars",
    tfstate = "json",
    hcl = "terraform",
    tm = "terraform",
  },
})

--opt.shortmess:append("sSIFWT")
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.iskeyword:append("-")
vim.keymap.set("", "<Space>", "<Nop>", { silent = true })

for _, vim_g_val in pairs(vim_g_options) do
  for k, v in pairs(vim_g_val) do
    g[k] = v
  end
end

for _, vim_opt_val in pairs(vim_opt_options) do
  for k, v in pairs(vim_opt_val) do
    opt[k] = v
  end
end
