return {
	-- Existing: JavaScript/TypeScript Debugger setup
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap", -- Ensure nvim-dap is installed
		},
		config = function()
			require("dap-vscode-js").setup({
				debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
				adapters = { "pwa-node", "pwa-chrome", "pwa-firefox", "pwa-msedge" },
			})

			local dap = require("dap") -- Re-require dap here for clarity in this config scope

			-- Your existing JS/TS configurations
			for _, language in ipairs({ "typescript", "javascript" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						protocol = "inspector",
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

	-- NEW: Go Debugger Integration (nvim-dap-go)
	{
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" }, -- Explicit dependency on nvim-dap
		config = function()
			-- Configure nvim-dap-go.
			-- Ensure 'delve' (the Go debugger) is installed via Mason (`:Mason`).
			-- The 'path' here is a common location if installed by Mason.
			require("dap-go").setup({
				delve = {
					path = vim.fn.stdpath("data") .. "/mason/bin/dlv",
				},
				-- Optional: You can specify custom delve flags, etc., here.
				-- dlv_args = { "--check-go-version=false" },
			})

			local dap = require("dap") -- Re-require dap here for clarity in this config scope

			-- Define Go debug configurations
			-- These configurations will appear when you try to launch or attach a debugger in a Go file.
			dap.configurations.go = {
				{
					type = "go",
					name = "Launch current file (Go)",
					request = "launch",
					program = "${file}", -- Debug the currently open Go file
					mode = "debug", -- Standard debugging mode
					buildFlags = "-gcflags=all=-N -l", -- Recommended for debugging (disables optimizations)
				},
				{
					type = "go",
					name = "Launch current package tests (Go)",
					request = "launch",
					program = "${fileDirname}", -- Debug tests for the package of the current file
					mode = "test", -- Important: tells delve to run in test mode
					buildFlags = "-gcflags=all=-N -l",
				},
				{
					type = "go",
					name = "Debug current test function (cursor) (Go)",
					request = "launch",
					program = "${fileDirname}",
					mode = "test",
					buildFlags = "-gcflags=all=-N -l",
					args = function()
						local test_name = vim.fn.expand("<cword>") -- Gets the function name under cursor
						-- This regex matches the exact test function name
						return { "-test.run", "^" .. test_name .. "$" }
					end,
				},
				-- You can add more configurations, e.g., "attach to process"
				-- {
				--   type = "go",
				--   name = "Attach to process (Go)",
				--   request = "attach",
				--   processId = require("dap.utils").pick_process,
				--   mode = "local",
				-- },
			}
		end,
	},

	-- NEW: Debug UI (nvim-dap-ui)
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio", -- Required by dap-ui for some features
		},
		config = function()
			local dap = require("dap") -- Re-require dap here
			local dapui = require("dapui") -- Require dapui itself

			-- Setup dapui with desired layouts and options
			dapui.setup({
				-- Default layouts are often good, but you can customize here.
				-- This is a common setup for a left sidebar with info and a bottom console.
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.25 }, -- Variables in current scope
							{ id = "breakpoints", size = 0.25 }, -- List of breakpoints
							{ id = "stacks", size = 0.25 }, -- Call stack
							{ id = "watches", size = 0.25 }, -- Watch expressions
						},
						size = 40, -- Width of the sidebar
						position = "left",
					},
					{
						elements = {
							{ id = "repl", size = 0.5 }, -- Read-Eval-Print Loop
							{ id = "console", size = 0.5 }, -- Debug console output
						},
						size = 10, -- Height of the bottom panel
						position = "bottom",
					},
				},
				-- You can add other dapui options here, e.g., 'controls', 'windows'
			})

			-- Automatically open/close DAP UI when debugging sessions start/end
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end
		end,
	},

	-- Important: If you want to configure core nvim-dap itself, you can add an entry like this.
	-- AstroNvim usually has its own base setup for `mfussenegger/nvim-dap`, so you might not
	-- need this unless you want to add very specific core DAP settings or keymaps here.
	{
		"mfussenegger/nvim-dap",
		-- Optional: Add a config function here if you have global DAP settings not covered by adapters
		-- config = function()
		--   local dap = require("dap")
		--   -- Example: Set a default log level for DAP
		--   -- dap.set_log_level("DEBUG")
		-- end
	},
}
