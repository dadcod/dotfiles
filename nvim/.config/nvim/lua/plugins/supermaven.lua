return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = false, -- Ensure it loads on startup (or adjust as needed)
    config = function() require("supermaven-nvim").setup {} end,
  },
}
