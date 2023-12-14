return {
  { "n", "<C-a>", "gg<S-v>G", "Select all" },
  { "n", "<C-s>", ":wq<CR>", "Write/Quit" },
  { "n", "<C-w>", ":wa<CR>", "Write/Quit all" },
  { "n", "<C-q>", ":q!<CR>", "Force Quit" },
  { "n", "p", "P", "Better Paste" },
  { "n", "<S-h>", ":bprevious<CR>", "Previous Buffer" },
  { "n", "<S-l>", ":bnext<CR>", "Next Buffer" },
  { "n", "<Space>wo", "<C-W>p", "Move to other window" }, -- other window
  { "n", "<Space>wd", "<C-W>c", "Delete window" }, -- delete window
  { "n", "<Space>wsb", "<C-W>s", "Split window below" }, -- split below
  { "n", "<Space>wsr", "<C-W>v", "Split window right" }, -- split right
  { "n", "wo", "<C-W>p", "Move to other window" }, -- other window
  { "n", "wq", "<C-W>c", "Delete window" }, -- delete window
  { "n", "wsn", ":FocusSplitNicely<cr>", "Slit Window Nicely (Focus)" }, -- split below
  { "n", "wsd", ":FocusSplitDown<cr>", "Split Window Below (Focus)" }, -- split below
  { "n", "wsr", ":FocusSplitRight<cr>", "Split Window Right (Focus)" }, -- split right
  { "n", "wsl", ":FocusSplitLeft<cr>", "Split Window Left (Focus)" }, -- split left
  { "n", "wsu", ":FocusSplitUp<cr>", "Split Window Above (Focus)" }, -- split up
  { "n", "<Space-w>s", "<C-w>w", "Window stuff" },
  { "n", "wl", "<C-w>h", "Move to Left Window" }, -- left window
  { "n", "wu", "<C-w>k", "Move to Window Above" }, -- up window
  { "n", "wd", "<C-w>j", "Move to Window Below" }, -- down window
  { "n", "wr", "<C-w>l", "Move to Right Window" }, -- right window
  { "n", "<c-up>", ":resize -2<cr>", "(-) size Horizontally" },
  { "n", "<c-down>", ":resize +2<cr>", "(+) size Horizontally" },
  { "n", "<c-right>", ":vertical resize -2<cr>", "(-) size Vertically" },
  { "n", "<c-left>", ":vertical resize +2<cr>", "(+) size Vertically" },
  -- { "n", "<tab>n", ":tabnew<Return>", "New Tab" }, -- New Tab
  -- { "n", "<tab>f", "<cmd>tabfirst<cr>", "Goto first Tab" }, -- first tab
  -- { "n", "<tab>l", "<cmd>tablast<cr>", "Goto last Tab" }, -- last tab
  -- { "n", "<tab>q", ":bdelete<CR>", "Delete Buffer" }, -- Delete tab
  --{ "n", "<tab>", "<cmd>BufferLineCycleNext<CR>", "Goto next Buffer" }, -- Next tab
  --{ "n", "<tab>p", "<cmd>BufferLineCyclePrev<CR>", "Goto previous Buffer" }, -- Previous tab
  { "n", "<space>h", ":nohlsearch<cr>", "Disable Nohl Search" }, -- No Highlight search
  { "v", "p", "_dP", "Paste over Selection" }, -- Paste over select text without yanking it
  { "v", "<", "<gv", "Indent left" },
  { "v", ">", ">gv", "Indent right" },
  { "i", "jk", "<esc>", "Exit Insert Mode" },
  { "i", "kj", "<esc>", "Exit Insert Mode" },
}
