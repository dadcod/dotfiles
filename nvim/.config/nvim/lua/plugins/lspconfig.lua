return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      tailwindcss = {
        filetypes = { "templ", "html", "css", "javascriptreact", "typescriptreact" },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                -- Add custom regex patterns here if needed
                -- For example, to match class names in your templ files
              },
            },
            includeLanguages = {
              templ = "html",
            },
          },
        },
      },
    },
  },
}
