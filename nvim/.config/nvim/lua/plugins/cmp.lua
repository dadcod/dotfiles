return {
  -- nvim-cmp: Completion engine
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- LSP completion source (optional, if using LSP)
      { "hrsh7th/cmp-nvim-lsp" },
      -- Buffer completion source
      { "hrsh7th/cmp-buffer" },
      -- Path completion source
      { "hrsh7th/cmp-path" },
      -- Command-line completion source
      { "hrsh7th/cmp-cmdline" },
      -- Snippet engine (optional)
      { "L3MON4D3/LuaSnip" },
      -- Snippet completions (optional)
      { "saadparwaiz1/cmp_luasnip" },
      -- VSCode-like snippets (optional)
      { "rafamadriz/friendly-snippets" },
      -- tailwindcss
      {
        "roobert/tailwindcss-colorizer-cmp.nvim",
      },
      { "onsails/lspkind.nvim" },
    },
    config = function()
      local cmp = require "cmp"
      local luasnip = require "luasnip"
      local lspkind = require "lspkind"
      local tailwindcss_colorizer_cmp = require "tailwindcss-colorizer-cmp"

      -- Load friendly-snippets (optional)
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup {
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        },
        sources = cmp.config.sources({
          { name = "luasnip" },
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),

        formatting = {
          format = function(entry, vim_item)
            -- Tailwind CSS colorizer
            vim_item = tailwindcss_colorizer_cmp.formatter(entry, vim_item)

            -- lspkind icons
            local kind_icon = lspkind.presets.default[vim_item.kind] or ""
            vim_item.kind = kind_icon .. " " .. (vim_item.kind or "")

            return vim_item
          end,
        },
      }

      -- Setup for command-line mode
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      -- Setup for search modes (`/` and `?`)
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },
}
