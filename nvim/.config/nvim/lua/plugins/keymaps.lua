return {
	{
		"AstroNvim/astrocore",
		---@type AstroCoreOpts
		opts = function(_, opts)
			local maps = opts.mappings

			-- Define the function to delete trailing comments
			local function delete_trailing_comment()
				local line = vim.api.nvim_get_current_line()
				local i = 1
				local in_string = false
				local str_char = nil
				while i <= #line do
					local c = line:sub(i, i)
					local next2 = line:sub(i, i + 1)

					if not in_string and (next2 == "//" or next2 == "--") then
						line = line:sub(1, i - 1):gsub("%s*$", "") -- trim before comment
						break
					elseif not in_string and c == "#" and i ~= 1 then
						line = line:sub(1, i - 1):gsub("%s*$", "")
						break
					elseif c == '"' or c == "'" then
						if in_string and c == str_char then
							in_string = false
							str_char = nil
						elseif not in_string then
							in_string = true
							str_char = c
						end
					end
					i = i + 1
				end
				vim.api.nvim_set_current_line(line)
			end

			function delete_trailing_comment_in_visual_mode()
				-- get start/end of visual selection
				local start_pos = vim.fn.getpos("'<")[2]
				local end_pos = vim.fn.getpos("'>")[2]

				for i = start_pos, end_pos do
					local line = vim.fn.getline(i)
					local idx = 1
					local in_string = false
					local str_char = nil

					while idx <= #line do
						local c = line:sub(idx, idx)
						local next2 = line:sub(idx, idx + 1)

						if not in_string and (next2 == "//" or next2 == "--") then
							line = line:sub(1, idx - 1):gsub("%s*$", "")
							break
						elseif not in_string and c == "#" and idx ~= 1 then
							line = line:sub(1, idx - 1):gsub("%s*$", "")
							break
						elseif c == '"' or c == "'" then
							if in_string and c == str_char then
								in_string = false
								str_char = nil
							elseif not in_string then
								in_string = true
								str_char = c
							end
						end

						idx = idx + 1
					end

					vim.fn.setline(i, line)
				end
			end

			-- Add the mapping for <leader>dc in Normal mode
			maps.n["<leader>da"] = { delete_trailing_comment, desc = "Delete Trailing Comment" }
			maps.v["<leader>da"] = { delete_trailing_comment_in_visual_mode, desc = "Delete Trailing Comment" }
			maps.n["]w"] = { "<C-w>w", desc = "Move to the next window" }
			maps.n["[w"] = { "<C-w>W", desc = "Move to the previous window" }

			maps.n["<leader>tt"] = {
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Run File",
			}
			maps.n["<leader>tF"] = {
				function()
					require("neotest").run.run(vim.uv.cwd())
				end,
				desc = "Run All Test Files",
			}
			maps.n["<leader>tr"] = {
				function()
					require("neotest").run.run()
				end,
				desc = "Run Nearest",
			}
			maps.n["<leader>tg"] = {
				function()
					require("neotest").run.run_last()
				end,
				desc = "Run Last",
			}
			maps.n["<leader>ts"] = {
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Toggle Summary",
			}
			maps.n["<leader>to"] = {
				function()
					require("neotest").output.open({ enter = true, auto_close = true })
				end,
				desc = "Show Output",
			}
			maps.n["<leader>tO"] = {
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Toggle Output Panel",
			}
			maps.n["<leader>tS"] = {
				function()
					require("neotest").run.stop()
				end,
				desc = "Stop",
			}
			maps.n["<leader>tw"] = {
				function()
					require("neotest").watch.toggle(vim.fn.expand("%"))
				end,
				desc = "Toggle Watch",
			}
			maps.n["<leader>td"] = {
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "Debug Test",
			}
			maps.n["<leader>tb"] = {
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			}
			maps.n["<leader>tc"] = {
				function()
					require("dap").continue()
				end,
				desc = "Debug Continue",
			}
			maps.n["<leader>tj"] = {
				function()
					require("dap").step_over()
				end,
				desc = "Debug Continue",
			}
			maps.n["<leader>ti"] = {
				function()
					require("dap").step_into()
				end,
				desc = "Debug Continue",
			}

			maps.n["<leader>fj"] = {
				"<cmd>lua require('custom.telescope_custom').search_project_classes()<CR>",
				desc = "Search Project Classes",
			}
			maps.n["<Leader> "] = {
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			}

			maps.n["<leader>fl"] = {
				"<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
				desc = "Live Grep With Glob",
			}

			-- maps.n["<leader>fl"] = {
			--   "<cmd>lua require('custom.telescope_custom').live_grep_with_dynamic_glob()<CR>",
			--   desc = "Live Grep With Glob",
			-- }

			maps.n["<leader>u"] = { ":UndotreeToggle<CR>", desc = "Toggle UndoTree" }

			maps.n["<leader>y"] = { desc = "Yank Utils" }
			maps.n["<leader>yf"] = { ":%y+<CR>", desc = "Yank Whole File" }
			maps.n["<leader>yp"] = {
				function()
					-- Copy the absolute path to the system clipboard
					vim.fn.setreg("+", vim.fn.expand("%:p"))

					-- Display a notification that the absolute path has been copied
					vim.notify(
						"Copied absolute path: " .. vim.fn.expand("%:p"),
						vim.log.levels.INFO,
						{ title = "Yanked!", timeout = 3000 }
					)
				end,
				desc = "Copy Buffer Absolute Path",
			}
			maps.n["<leader>yr"] = {
				function()
					-- Copy the relative path to the system clipboard
					vim.fn.setreg("+", vim.fn.expand("%"))

					-- Display a notification that the relative path has been copied
					vim.notify(
						"Copied relative path: " .. vim.fn.expand("%"),
						vim.log.levels.INFO,
						{ title = "Yanked!", timeout = 3000 }
					)
				end,
				desc = "Copy Buffer Relative Path",
			}
			-- Copy file name with line number
			maps.n["<leader>yl"] = {
				function()
					-- Get file name and line number
					local file_name = vim.fn.expand("%:t")
					local line_number = vim.fn.line(".")
					local file_with_line = file_name .. ":" .. line_number

					-- Copy to system clipboard
					vim.fn.setreg("+", file_with_line)

					-- Notify user
					vim.notify(
						"Copied file name with line: " .. file_with_line,
						vim.log.levels.INFO,
						{ title = "Yanked!", timeout = 3000 }
					)
				end,
				desc = "Copy File Name with Line Number",
			}
			-- Copy symbol under cursor
			maps.n["<leader>ys"] = {
				function()
					-- Attempt to use LSP to get the symbol
					local symbol = vim.lsp.buf.hover and vim.fn.expand("<cword>") or vim.fn.expand("<cword>")
					if not symbol then
						vim.notify("No symbol found under cursor", vim.log.levels.WARN, { title = "Error" })
						return
					end

					-- Copy to system clipboard
					vim.fn.setreg("+", symbol)

					-- Notify user
					vim.notify("Copied symbol: " .. symbol, vim.log.levels.INFO, { title = "Yanked!", timeout = 3000 })
				end,
				desc = "Copy Symbol under Cursor",
			}

			maps.n["<leader>yb"] = {
				function()
					local heirline = require("heirline")

					-- Evaluate the current winbar content
					local winbar_content = heirline.eval_winbar()

					-- Fallback if no winbar content is available
					if not winbar_content or winbar_content == "" then
						vim.notify("No breadcrumbs available.", vim.log.levels.WARN, { title = "Error" })
						return
					end

					-- Clean formatting strings and fix spacing issues
					local cleaned_content = winbar_content
						:gsub("%%#.-#%%*", "") -- Remove %#...# formatting
						:gsub("%%*", "") -- Remove any stray %* formatting
						:gsub("^%s*…%s*%s*", "") -- Remove leading dots and separator
						:gsub("", "/") -- Replace `` with `/`
						:gsub("", "") -- Remove the symbol ``
						:gsub("%*", "") -- Remove asterisks `*`
						:gsub("%s*/%s*", "/") -- Remove spaces around slashes
						:gsub("%s+", " ") -- Replace multiple spaces with a single space
						:gsub("^%s+", "") -- Trim leading spaces
						:gsub("%s+$", "") -- Trim trailing spaces

					-- Retrieve the current function or method using LSP
					local current_function = ""
					if vim.lsp.buf_get_clients() then
						local params = vim.lsp.util.make_position_params()
						local result = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000) -- Sync request

						if result then
							for _, response in pairs(result) do
								local function find_function(symbols)
									for _, symbol in ipairs(symbols) do
										local start_line = symbol.range.start.line
										local end_line = symbol.range["end"].line
										if vim.fn.line(".") - 1 >= start_line and vim.fn.line(".") - 1 <= end_line then
											if symbol.kind == 12 or symbol.kind == 22 then -- Function or Method
												return symbol.name
											end
											if symbol.children then
												local child_function = find_function(symbol.children)
												if child_function then
													return child_function
												end
											end
										end
									end
								end

								if response.result then
									current_function = find_function(response.result) or vim.fn.expand("<cword>")
									break
								end
							end
						else
							current_function = vim.fn.expand("<cword>")
						end
					else
						-- Fallback to current word if LSP is unavailable
						current_function = vim.fn.expand("<cword>")
					end

					-- Append the current function to the breadcrumbs with a colon separator
					local final_content = string.format("%s:%s", cleaned_content, current_function)

					-- Copy the final content to clipboard
					vim.fn.setreg("+", final_content)

					-- Notify the user
					vim.notify(
						"Copied breadcrumbs: " .. final_content,
						vim.log.levels.INFO,
						{ title = "Yanked!", timeout = 3000 }
					)
				end,
				desc = "Copy Breadcrumbs with Deepest Function Context",
			}

			maps.n["]w"] = { "<C-w>w", desc = "Move to the next window" }

			-- Normal-mode commands
			maps.n["<A-j>"] = { ":MoveLine(1)<CR>", desc = "Move Line Down", silent = true }
			maps.n["<A-k>"] = { ":MoveLine(-1)<CR>", desc = "Move Line Up", silent = true }
			maps.n["<A-h>"] = { ":MoveHChar(-1)<CR>", desc = "Move Line Up", silent = true }
			maps.n["<A-l>"] = { ":MoveHChar(1)<CR>", desc = "Move Line Down", silent = true }

			-- Visual-mode commands
			maps.v["<A-j>"] = { ":MoveBlock(1)<CR>", desc = "Move Line Down", silent = true }
			maps.v["<A-k>"] = { ":MoveBlock(-1)<CR>", desc = "Move Line Up", silent = true }
			maps.v["<A-h>"] = { ":MoveHBlock(-1)<CR>", desc = "Move Line Up", silent = true }
			maps.v["<A-l>"] = { ":MoveHBlock(1)<CR>", desc = "Move Line Down", silent = true }

			local ng = require("ng")
			maps.n["<leader>at"] = {
				function()
					ng.goto_template_for_component()
				end,
				silent = true,
				desc = "Go to template",
			}
			maps.n["<leader>ac"] = {
				function()
					ng.goto_component_with_template_file()
				end,
				silent = true,
				desc = "Go to component",
			}
			maps.n["<leader>aT"] = {
				function()
					ng.get_template_tcb()
				end,
				silent = true,
				desc = "Go to usages in templates",
			}

			maps.n["gd"] = {
				function()
					vim.lsp.buf.definition()
				end,
				desc = "Go to Definition",
			}
			maps.n["gr"] = {
				function()
					vim.lsp.buf.references()
				end,
				desc = "Find References",
			}
			-- Require the necessary plugins
			local luasnip = require("luasnip")
			local cmp = require("cmp")

			-- Helper functions for snippet navigation
			local function has_words_before()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			-- Tab mapping
			maps.i["<Tab>"] = {
				function()
					if luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					elseif cmp and cmp.visible() then
						cmp.select_next_item()
					elseif has_words_before() then
						cmp.complete()
					else
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", false)
					end
				end,
				desc = "Snippet expand or jump",
				silent = true,
			}

			-- Shift-Tab mapping
			maps.i["<S-Tab>"] = {
				function()
					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					elseif cmp and cmp.visible() then
						cmp.select_prev_item()
					else
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true), "n", false)
					end
				end,
				desc = "Snippet jump backward",
				silent = true,
			}

			-- Also map in select mode
			maps.s["<Tab>"] = maps.i["<Tab>"]
			maps.s["<S-Tab>"] = maps.i["<S-Tab>"]

			-- Spectre mappings
			maps.n["<leader>R"] = {
				function()
					require("spectre").open()
				end,
				desc = "Open Spectre for search and replace",
			}
			maps.n["<leader>rw"] = {
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search current word",
			}
			maps.v["<leader>rs"] = {
				function()
					require("spectre").open_visual()
				end,
				desc = "Search visually selected text",
			}

			opts.mappings = maps
		end,
	},
	{
		"AstroNvim/astrolsp",
		---@type AstroLSPOpts
		opts = {
			mappings = {
				n = {
					["<leader>fu"] = {
						function()
							local builtin = require("telescope.builtin")
							local previewers = require("telescope.previewers")

							-- Debugging: Check the previewers table itself
							if not previewers then
								vim.notify("Telescope previewers table not found!", vim.log.levels.ERROR)
								return
							end

							-- Debugging: Check the vim_buffer_vimgrep field
							local vimgrep_table = previewers.vim_buffer_vimgrep
							if not vimgrep_table then
								vim.notify("previewers.vim_buffer_vimgrep not found!", vim.log.levels.ERROR)
								return
							end
							-- Ensure it's actually a table as inspect showed
							if type(vimgrep_table) ~= "table" then
								vim.notify(
									"previewers.vim_buffer_vimgrep is not a table! Type: " .. type(vimgrep_table),
									vim.log.levels.ERROR
								)
								return
							end

							-- Debugging: Check the .new field *within* the table
							local vimgrep_constructor = vimgrep_table.new
							if not vimgrep_constructor then
								vim.notify("previewers.vim_buffer_vimgrep.new not found!", vim.log.levels.ERROR)
								return
							end
							-- Ensure it's a function
							if type(vimgrep_constructor) ~= "function" then
								vim.notify(
									"previewers.vim_buffer_vimgrep.new is not a function! Type: "
										.. type(vimgrep_constructor),
									vim.log.levels.ERROR
								)
								return
							end

							-- If all checks pass, proceed
							builtin.lsp_references({
								include_declaration = false,
								-- Call the constructor we just verified
								previewer = vimgrep_constructor({
									-- Optional: Previewer options here if needed
									surrounding_lines = 10,
									jump_to_line = true,
									use_entry_lnum = true,
								}),
								-- Optional: Customize path display if desired
								path_display = { "smart" },
							})
						end,
						desc = "Find Usages (LSP References)",
					},
					["<leader>fc"] = {
						function()
							local word = vim.fn.expand("<cword>") -- Get the word under the cursor
							require("telescope.builtin").grep_string({
								initial_mode = "normal",
								search = word,
							})
							vim.cmd("set hlsearch") -- Enable search highlighting
						end,
						desc = "Find Word Under Cursor",
					},
				},
			},
		},
	},
}
