-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
	vim.fn.getchar()
	vim.cmd.quit()
end

local function delete_trailing_comment()
	local comment_str = vim.bo.commentstring
	-- Extract the comment prefix (e.g., "// " from "// %s")
	local left = comment_str:match("^([^%s]*)%%s.*") or ""
	-- Escape special regex characters in the comment prefix
	left = vim.fn.escape(left, "/\\*$.^[]~")

	-- Fallback to common comment symbols if none found
	if left == "" then
		left = '//|#|--|"'
		left = left:gsub("|", "\\|")
		left = "\\(" .. left .. "\\)" -- Capture group for alternation
	end

	-- Pattern: any whitespace, comment prefix, remaining text until line end
	local pattern = "\\s*" .. left .. "\\s*.*$"
	-- Execute substitution without moving cursor (keepjumps)
	vim.cmd("silent! keepjumps " .. vim.fn.line(".") .. "s/" .. pattern .. "//")
end

-- Map 'dc' in normal mode to the function
vim.keymap.set("n", "dc", delete_trailing_comment, { desc = "Delete trailing comment" })
require("lazy_setup")
require("polish")
require("user.lsp.config")
