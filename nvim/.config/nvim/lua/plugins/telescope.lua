-- ~/.config/nvim/lua/user/plugins/telescope.lua

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				live_grep_args = {},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
				defaults = {
					file_ignore_patterns = {
						"node_modules",
						"vendor",
					},
					path_display = { "smart" }, -- Display only the tail of the path if it makes sense
					layout_config = {
						horizontal = { preview_width = 0.5 }, -- Adjust preview width
					},
					dynamic_preview_title = true, -- Show a dynamic title in the preview
				},
				pickers = {
					lsp_references = {
						path_display = { "tail" }, -- Show only the file name

						entry_maker = function(entry)
							if not entry or type(entry) ~= "table" then
								return nil -- Handle cases where entry is invalid
							end

							local filename = entry.filename or entry[1] or "<unknown>"
							filename = vim.fn.fnamemodify(filename, ":t") -- Extract the tail of the filename
							local icon = require("nvim-web-devicons").get_icon(filename, nil, { default = true })
							return {
								value = entry,
								display = string.format("%s %s", icon or "?", filename),
								ordinal = filename .. " " .. (entry.text or ""),
								filename = entry.filename,
							}
						end,
						layout_config = {
							preview_width = 0.5, -- Adjust preview width for references
						},
					},
				},
			})
			telescope.load_extension("fzf")
			telescope.load_extension("live_grep_args")
		end,
	},
}
