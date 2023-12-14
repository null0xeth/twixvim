local settings = {
  colorschemes = {
    catppuccin = true,
    darkplus = false,
    tokyonight = false,
    material = false,
    rosepine = false,
  },
  languages = {
    cpp = true,
    css = true,
    dotfiles = true,
    helm = false,
    json = true,
    lua = true,
    markdown = false,
    nix = true,
    python = false,
    rust = true,
    solidity = false,
    typescript = false,
    yaml = true,
  },
  keymap_categories = {
    --a = false,
    prefix = "<leader>",
    mode = { "n", "v" },
    b = {
      name = "+Buffer",
    },
    c = {
      name = "+Coding",
      t = { "+Trouble (QF)" },
      T = { "+TODO Comments" },
    },
    d = {
      name = "+Nvim DAP",
      a = { "+Adapters" },
      u = {
        name = "+DAP UI",
        f = { "+Float elements.." },
        v = { "+Virtual Text" },
        w = { "+UI Widgets" },
      },
    },
    e = {
      name = "+Editor",
      f = { "+Folding" },
    },
    f = {
      name = "+Telescope",
      d = { "+Diagnostics" },
      D = { "+DAP Telescope" },
      f = { "+Normal Search" },
      g = { "+General" },
      G = { "+Git" },
      l = { "+LSP" },
      z = { "+Fuzzy Search" },
    },
    g = {
      name = "+Git",
      s = {
        name = "+Gitsigns",
        h = { "+Hunk" },
        b = { "+Buffer" },
        l = { "+Line" },
      },
    },
    --h = false,
    --i = false,
    --j = false,
    --k = false,
    l = {
      name = "+LSP",
      a = { "+Annotations" },
      g = { "+Glance" },
      c = { "+Code Navigation" },
    },
    m = {
      name = "+Movement",
      r = { "+Reach" },
      n = { "+Navigation" },
    },
    --n = false,
    --o = false,
    p = { name = "+Persistence" },
    --q = false,
    r = {
      name = "+Refactoring", -- add search.lua sjit
    },
    s = {
      name = "+Search",
      s = { "+Nvim Spectre" },
      r = { "+SSR" },
    },
    S = { name = "+Syntax" },
    t = {
      name = "+Testing",
      n = { "+Neotest" },
      o = { "+Overseer" },
      v = { "+Vim Test" },
    },
    u = {
      name = "+UI/Windows",
      n = { "+Noice (Notifications)" },
    },
    v = {
      name = "+View",
      s = { "+Symbols" },
      w = {
        name = "+Windows",
        s = { "+Splits" },
      },
    },
    --w = false,
    --x = false,
    --y = false,
    --z = false,
  },
}

return settings
