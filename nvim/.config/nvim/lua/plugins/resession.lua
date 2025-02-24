return {
  -- Add the Resession plugin
  {
    "stevearc/resession.nvim",
    config = function()
      require("resession").setup {
        -- Optional: auto-save on exit, useful to auto-save sessions
        autosave = {
          enabled = true,
        }
      }
    end,
  },
}
