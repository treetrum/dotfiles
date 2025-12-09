return {
  "liouk/gitlinks.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gitlinks").setup()
  end,
}
