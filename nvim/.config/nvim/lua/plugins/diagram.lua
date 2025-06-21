return {
	{
		"3rd/diagram.nvim",
		-- You can specify events, commands, or filetypes to lazy load it,
		-- or leave it empty to load on startup (or as per lazy.nvim defaults).
		-- event = "VeryLazy", -- Example: Load after most other things
		-- cmd = { "DiagramCreate" }, -- Example: Load when DiagramCreate command is used

		-- The plugin doesn't seem to require a .setup() call with specific options
		-- in its basic README, but if you find advanced configurations,
		-- you would add them in a `opts = {}` table or a `config = function() ... end` block.
		config = function()
			-- Optional: If the plugin has a setup function you want to call or
			-- if you want to set global variables/options related to it, do it here.
			-- For diagram.nvim, it mostly relies on its commands and autocommands.
			-- Example: Set a global variable if needed (check plugin docs for actual options)
			-- vim.g.diagram_auto_preview = true

			-- The plugin mentions that previews are done in a floating window by default.
			-- It also registers autocommands for specific filetypes like .drawio, .dot, etc.
			-- to automatically show previews.
		end,

		-- If the plugin has dependencies that are also Neovim plugins and
		-- managed by lazy.nvim, you can list them here.
		-- For diagram.nvim, the main dependencies are external system libraries.
		-- dependencies = {
		--   "nvim-lua/plenary.nvim", -- Example if it needed plenary
		-- },
	},
}
