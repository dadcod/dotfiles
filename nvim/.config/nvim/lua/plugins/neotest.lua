return {
  {
    "nvim-neotest/neotest",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "haydenmeade/neotest-jest",
    },
    config = function()
      local function find_nearest_node_modules()
        local dir = vim.fn.expand "%:p:h" -- start from the current file's directory
        while dir and dir ~= "/" do
          local node_modules_path = dir .. "/node_modules/jest/bin/jest.js"
          if vim.fn.filereadable(node_modules_path) == 1 then return node_modules_path end
          dir = vim.fn.fnamemodify(dir, ":h") -- go up one level
        end
        return nil -- return nil if not found
      end

      require("neotest").setup {
        adapters = {
          require "neotest-jest" {
            jestCommand = function()
              local file_path = vim.fn.expand "%:p"
              local jest_path = find_nearest_node_modules() or "jest" -- fallback to "jest" if not found
              local node_path = "/usr/local/bin/node" -- adjust this if necessary

              local cmd = string.format("%s %s --colors --verbose --runTestsByPath %s", node_path, jest_path, file_path)
              return cmd
            end,
            cwd = function() return vim.fn.getcwd() end,
            env = { NODE_ENV = "test" },
            jestConfigFile = function()
              local file_path = vim.fn.expand "%:p"
              local project_name = file_path:match "apps/(.-)/" or file_path:match "libs/(.-)/"
              if project_name and project_name ~= "" then return "apps/" .. project_name .. "/jest.config.js" end
              return vim.fn.getcwd() .. "/jest.config.js"
            end,
          },
        },
      }
    end,
  },
}
