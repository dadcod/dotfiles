---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "javascript",
      "typescript",
    },
    highlight = {
      enagle = true,
      additional_vim_regex_highlighting = { "templ" },
    },
  },
}
