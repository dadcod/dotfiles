local M = {}

function M.search_project_classes()
  require("telescope.builtin").lsp_dynamic_workspace_symbols({
    symbols = "Class",
    query = "a"
  })
end

function M.live_grep_with_dynamic_glob()
  -- Prompt for multiple file extensions
  local extensions = vim.fn.input("File extensions (comma-separated, e.g., lua, js, py): ")

  if extensions == "" then
    print("No extensions provided!")
    return
  end

  -- Generate a glob pattern for each extension
  local glob_patterns = {}
  for ext in string.gmatch(extensions, '([^,]+)') do
    table.insert(glob_patterns, "*." .. ext)
  end

  -- Perform live_grep using the fzf extension with multiple glob patterns
  require("telescope.builtin").live_grep({
    prompt_title = "< Grep Files with Extensions >",
    glob_pattern = table.concat(glob_patterns, ","), -- Combine glob patterns
  })
end

return M
