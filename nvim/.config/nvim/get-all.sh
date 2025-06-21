#!/bin/zsh

# --- Configuration ---
OUTPUT_FILE="combined_repo_output.txt"
INCLUDE_EXTENSIONS=(
    "json" "ts" "tsx" "js" "jsx" "html" "htm" "css" "scss" "sass" "less"
    "py" "java" "c" "cpp" "h" "hpp" "cs" "go" "rb" "php" "swift" "kt" "kts"
    "yaml" "yml" "md" "sh" "bash" "zsh" "sql" "xml" "dockerfile" "Makefile"
    "gradle" "pom.xml" "gitignore" "env" "config" "cfg" "ini" "toml" "mjs" "lua" "vim"
)
EXCLUDE_DIRS=("node_modules" ".angular" ".nx" "dist" "build" ".git" ".vscode" ".idea" "__pycache__" "target" "pack")
EXCLUDE_PATHS=(
    "dist" "build" "target" # Common top-level build output dirs
    # Add specific top-level paths like "docs/generated" if needed
)
EXCLUDE_FILES=(
    ".DS_Store" "package-lock.json" "yarn.lock" "*.lock"
    "*.pyc" "*.pyo" "*.log" "*.tmp" "*.temp" "*.min.js" "*.min.css"
    "*.svg" "*.png" "*.jpg" "*.jpeg" "*.gif" "*.ico" "*.webp"
    "*.woff" "*.woff2" "*.ttf" "*.otf" "*.eot"
    # Output file name will be added later
)
BAR_WIDTH=50 # Width of the progress bar in characters

# --- Helper Functions ---
# (print_progress function remains the same as the previous version)
print_progress() {
    local current=$1
    local total=$2
    local width=$3
    local title=$4
    local percent
    local completed
    local remaining
    local bar
    local empty

    if [ "$total" -le 0 ]; then # Handle total=0 case
        percent=100
        current=0
        total=0
    else
        if (( current >= total )); then
            percent=100
        else
             local current_x_100=$(( current * 100 ))
             percent=$(( current_x_100 / total ))
        fi
    fi

    (( percent > 100 )) && percent=100
    (( percent < 0 )) && percent=0

    completed=$(( (percent * width) / 100 ))
    remaining=$((width - completed))

    (( completed < 0 )) && completed=0
    (( remaining < 0 )) && remaining=0
    bar=$(printf "%${completed}s" | tr ' ' '#')
    empty=$(printf "%${remaining}s" | tr ' ' '-')

    printf "\r%s: [%s%s] %d%% (%d / %d bytes)" "$title" "$bar" "$empty" "$percent" "$current" "$total" >&2
}

# --- Main Script ---

# 1. Find Git Project Root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$PROJECT_ROOT" ]; then
  echo "Error: Not inside a Git repository or 'git' command failed." >&2
  exit 1
fi
echo "Project Root: $PROJECT_ROOT" >&2
cd "$PROJECT_ROOT" || exit 1 # Change to root for consistent paths
OUTPUT_FILE_PATH="$PROJECT_ROOT/$OUTPUT_FILE" # Define full output path

# Add output file basename to EXCLUDE_FILES
EXCLUDE_FILES+=("$(basename "$OUTPUT_FILE_PATH")")
# Add self script name to EXCLUDE_FILES
# Get script name even if called with relative path
# SCRIPT_NAME=$(basename "$0") # $0 might be './proc.sh'
# Use absolute path then basename for robustness
# This assumes $0 holds the path used to invoke the script
# Use Zsh specific way to get script path: ${(%):-%x}
# SCRIPT_PATH=$(readlink -f "${(%):-%x}") # Requires readlink, might not be default on mac
# Simpler: Just use $0 and rely on cd to PROJECT_ROOT
SCRIPT_NAME=$(basename "$0") # Should be 'proc.sh' if run as ./proc.sh
EXCLUDE_FILES+=("$SCRIPT_NAME") # Exclude the script file itself


# Combine all exclude patterns for tree
ALL_EXCLUDE_PATTERNS=("${EXCLUDE_DIR_NAMES[@]}" "${EXCLUDE_PATHS[@]}" "${EXCLUDE_FILES[@]}")

# 2. Check for 'tree' command
# (Tree check remains the same)
if ! command -v tree &> /dev/null; then
    echo "Warning: 'tree' command not found. Skipping tree generation." >&2
    TREE_AVAILABLE=false
else
    TREE_AVAILABLE=true
fi

# 3. Prepare 'find' arguments (remains the same)
FIND_ARGS=(".")
if [ ${#EXCLUDE_DIRS[@]} -gt 0 ]; then
  FIND_ARGS+=(\( -false)
  for dir in "${EXCLUDE_DIRS[@]}"; do
    FIND_ARGS+=(-o -path "./$dir")
  done
  FIND_ARGS+=(\) -prune -o)
fi
FIND_ARGS+=(-type f)
if [ ${#INCLUDE_EXTENSIONS[@]} -gt 0 ]; then
  FIND_ARGS+=(\( -false)
  for ext in "${INCLUDE_EXTENSIONS[@]}"; do
    FIND_ARGS+=(-o -name "*.$ext")
  done
  FIND_ARGS+=(\))
fi
if [ ${#EXCLUDE_FILES[@]} -gt 0 ]; then
    for pattern in "${EXCLUDE_FILES[@]}"; do
        if [[ -n "$pattern" ]]; then
            # Use -path for exact match relative to ., safer than -name for script/output file
            if [[ "$pattern" == *"*"* ]]; then
                 FIND_ARGS+=(-not -name "$pattern") # Handle wildcards with -name
            else
                 FIND_ARGS+=(-not -path "./$pattern") # Handle exact files with -path
            fi
        fi
    done
fi
FIND_ARGS+=(-print0)

# Prepare tree ignore string (remains the same)
TREE_IGNORE_STR=""
for pattern in "${ALL_EXCLUDE_PATTERNS[@]}"; do
  if [[ -z "$pattern" ]]; then continue; fi
  if [ -n "$TREE_IGNORE_STR" ]; then
    TREE_IGNORE_STR+="|"
  fi
  TREE_IGNORE_STR+="$pattern"
done
# echo "Debug: Tree ignore pattern: '$TREE_IGNORE_STR'" >&2

# 4. Generate Tree Structure and Write Header (remains the same)
echo "Generating project structure..." >&2
{
  echo "Project: $(basename "$PROJECT_ROOT")"
  echo "Generated: $(date)"
  echo "======================="
  echo "Project Tree Structure:"
  echo "======================="
} > "$OUTPUT_FILE_PATH"

if $TREE_AVAILABLE; then
    # echo "Debug: Running tree command: tree -a -I \"$TREE_IGNORE_STR\"" >&2
    tree_stderr=$(tree -a -I "$TREE_IGNORE_STR" >> "$OUTPUT_FILE_PATH" 2>&1)
    tree_exit_code=$?
    if [[ $tree_exit_code -ne 0 ]]; then
        echo "Warning: 'tree' command exited with status $tree_exit_code. Structure might be incomplete or missing." >&2
        echo "[tree command failed or was interrupted (exit code: $tree_exit_code)]" >> "$OUTPUT_FILE_PATH"
        # if [[ -n "$tree_stderr" ]]; then echo "Debug: Tree stderr: $tree_stderr" >&2; fi
    fi
else
    echo "[Skipped: 'tree' command not found]" >> "$OUTPUT_FILE_PATH"
fi

{
  echo ""
  echo "======================="
  echo "Combined File Contents:"
  echo "======================="
  echo ""
} >> "$OUTPUT_FILE_PATH"


# 5. Find Files, Validate, and Calculate Total Size (NEW APPROACH)
echo "Finding relevant files, validating, and calculating total size..." >&2
declare -a FILES_TO_PROCESS # Final list
TOTAL_SIZE=0
file_count=0
processed_files_debug_count=0 # Counter for debug output

# Use process substitution with a while loop to read null-delimited output
# The '-r' option prevents backslash interpretation, '-d '\0'' reads until null
while IFS= read -r -d $'\0' file; do
    # Debug: Print periodically to show progress during find/validation
    processed_files_debug_count=$((processed_files_debug_count + 1))
    if (( processed_files_debug_count % 500 == 0 )); then
       echo "Debug: Processed ${processed_files_debug_count} files found by find..." >&2
    fi

    # Basic check if file path seems reasonable (not empty)
    if [[ -z "$file" ]]; then
        # echo "Debug: Skipping empty file path from find." >&2
        continue;
    fi

    # Check if file exists, is a regular file, and is readable
    if [[ -f "$file" && -r "$file" ]]; then
        size=$(stat -f %z "$file" 2>/dev/null)
        stat_exit_code=$?
        if [[ $stat_exit_code -eq 0 && -n "$size" ]]; then
            TOTAL_SIZE=$((TOTAL_SIZE + size))
            FILES_TO_PROCESS+=("$file") # Add to the final list
            file_count=$((file_count + 1))
        else
            echo "Warning: Could not get size for '$file' (stat exit code: $stat_exit_code)" >&2
        fi
    else
         reason=""
         if [[ ! -f "$file" ]]; then reason="not a regular file"; fi
         if [[ ! -r "$file" ]]; then reason="$reason (or not readable)"; fi
         # Reduce noise by commenting this out unless needed
         # echo "Warning: Skipping '$file' ($reason)" >&2
    fi
done < <(find "${FIND_ARGS[@]}") # Feed find output directly to the loop

echo "Found $file_count valid, readable files to combine after filtering. Total size: $TOTAL_SIZE bytes." >&2

if [ "$file_count" -eq 0 ]; then
    echo "No relevant, readable files found matching criteria after filtering." >&2
    echo "[No relevant, readable files found]" >> "$OUTPUT_FILE_PATH"
    echo "Debug: Check the find command arguments used (see above if debug enabled). Verify exclusion/inclusion patterns and file permissions." >&2
    exit 0
fi

# 6. Combine Files with Progress Bar (remains the same)
echo "Combining files into $(basename "$OUTPUT_FILE_PATH")..." >&2
PROCESSED_SIZE=0
# Ensure output file exists before appending in loop
# touch "$OUTPUT_FILE_PATH" # Header creation already does this

# Initial progress bar display
print_progress 0 "$TOTAL_SIZE" "$BAR_WIDTH" "Combining"

for file in "${FILES_TO_PROCESS[@]}"; do
    printf "\n--- File: %s ---\n" "$file" >> "$OUTPUT_FILE_PATH"
    cat_stderr=""
    if cat "$file" >> "$OUTPUT_FILE_PATH" 2> >(cat_stderr=$(cat); echo "$cat_stderr" >&2) ; then
        size=$(stat -f %z "$file" 2>/dev/null)
         if [ $? -eq 0 ] && [[ -n "$size" ]]; then
            PROCESSED_SIZE=$((PROCESSED_SIZE + size))
        fi
    else
        local cat_exit_code=$?
        echo "\nWarning: Failed to cat file '$file' (exit code $cat_exit_code)." >&2
        echo "[Error reading file: $file (cat exit code: $cat_exit_code)]" >> "$OUTPUT_FILE_PATH"
        # if [[ -n "$cat_stderr" ]]; then echo "Debug: cat stderr for '$file': $cat_stderr" >&2; fi
    fi
    echo "" >> "$OUTPUT_FILE_PATH"
    print_progress "$PROCESSED_SIZE" "$TOTAL_SIZE" "$BAR_WIDTH" "Combining"
done

# Final progress bar update and summary (remains the same)
print_progress "$TOTAL_SIZE" "$TOTAL_SIZE" "$BAR_WIDTH" "Combining"
echo "" >&2

echo "✅ Combining complete." >&2
echo "   Output written to: $OUTPUT_FILE_PATH" >&2
echo "   Total files combined: $file_count" >&2
echo "   Total size processed: $PROCESSED_SIZE bytes (target was $TOTAL_SIZE bytes)" >&2

exit 0
