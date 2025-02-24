return {
  {
    "mxsdev/nvim-dap-vscode-js",
    requires = {
      "mfussenegger/nvim-dap", -- Ensure nvim-dap is installed
    },
    config = function()
      require("dap-vscode-js").setup {
        debugger_path = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter",
        adapters = { "pwa-node", "pwa-chrome", "pwa-firefox", "pwa-msedge" },
      }

      local dap = require "dap"

      -- Explicitly configure the pwa-node adapter and ensure the port is specified
      -- dap.adapters["pwa-node"] = {
      --   type = "server",
      --   host = "127.0.0.1",
      --   port = 9229, -- Ensure the port is explicitly set for the adapter
      --   executable = {
      --     command = "node",
      --     args = { vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js" }, -- Path to js-debug adapter
      --   }
      -- }

      for _, language in ipairs { "typescript", "javascript" } do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector", -- Ensure using inspector protocol
            console = "integratedTerminal",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
          },
        }
      end
    end,
  },
}
