vim.filetype.add { extension = { templ = "templ" } }

local custom_format = function()
  if vim.bo.filetype == "templ" then
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local cmd = "templ fmt " .. vim.fn.shellescape(filename)

    vim.fn.jobstart(cmd, {
      on_exit = function()
        if vim.api.nvim_get_current_buf() == bufnr then vim.cmd "e!" end
      end,
    })
  else
    vim.lsp.buf.format()
  end
end

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<leader>lf", custom_format, opts)
  end

  require("tailwindcss-colors").buf_attach(bufnr)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require "lspconfig"

lspconfig.templ.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

lspconfig.tailwindcss.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "templ", "html", "css", "javascriptreact", "typescriptreact", "typescript", "javascript" },
  init_options = { userLanguages = { templ = "html" } },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        templ = "html",
      },
      experimental = {
        classRegex = {
          -- If you have custom class patterns, define them here
        },
      },
    },
  },
}

-- Remove "templ" from html LSP if not needed
lspconfig.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html" },
}
local cmd = {
  "ngserver",
  "--stdio",
  "--tsProbeLocations",
  "/Users/rosenpetkov/.nvm/versions/node/v18.18.2/lib/node_modules",
  "--ngProbeLocations",
  "/Users/rosenpetkov/.nvm/versions/node/v18.18.2/lib/node_modules",
}

lspconfig.angularls.setup {
  cmd = cmd,
  root_dir = function(fname)
    local root = lspconfig.util.root_pattern("project.json", "angular.json", "workspace.json", "nx.json", ".git")(fname)
    return root
  end,

  on_attach = on_attach,
  capabilities = capabilities,
  on_new_config = function(new_config, new_root_dir) new_config.cmd = cmd end,
  filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
  init_options = {
    ngProbeLocations = { "/Users/rosenpetkov/.nvm/versions/node/v18.18.2/lib/node_modules" },
    typescriptProbeLocations = { "/Users/rosenpetkov/.nvm/versions/node/v18.18.2/lib/node_modules" },
    diagnosticOptions = {
      semantic = true,
      declaration = true,
      template = true,
    },
  },
}

-- Configure nvim-cmp
local cmp = require "cmp"
cmp.setup {
  mapping = cmp.mapping.preset.insert {
    -- Your existing mappings...
  },
  sources = cmp.config.sources {
    { name = "nvim_lsp" },
    -- Include luasnip if using snippets
    { name = "luasnip" },
    -- Other sources...
    { name = "supermaven" },
  },
}

require("nvim-treesitter.configs").setup {
  ensure_installed = { "templ" },
  sync_install = false,
  auto_install = true,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
  },
}
require("lazy").setup({
  {
    "supermaven-inc/supermaven-nvim",
    config = function() require("supermaven-nvim").setup {} end,
  },
}, {})
