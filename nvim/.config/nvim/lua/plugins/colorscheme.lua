return {
  -- Add theme
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon", transparent = "true" },
  },

  -- Configure LazyVim to use the theme
  { "LazyVim/LazyVim", opts = {
    colorscheme = "tokyonight",
  } },
}
