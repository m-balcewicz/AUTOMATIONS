#!/bin/zsh
# Directory Storage Analyzer - Hierarchical directory tree with file sizes
# Efficiently processes directories level by level to show storage usage
# Works with any directory path, not just iCloud

set -euo pipefail

# Default configuration - can be overridden by command line arguments
DEFAULT_DIR="$HOME"
TARGET_DIR=""
MIN_SIZE="${MIN_SIZE:-}"
INCLUDE_FILES=1
CHILD_LIMIT=20

usage(){
  echo "Usage: dir_storage.zsh [-s MIN_FILE_SIZE] [-f] [-h] [-L LIMIT] [-d DIR]"
  echo "  -s SIZE   Minimum file size (e.g. 100M, 1G). If omitted you will be prompted."
  echo "  -f        Include large files (>= SIZE) in tree (default ON)"
  echo "  -L LIMIT  Limit number of children shown per directory (default 20)"
  echo "  -d DIR    Directory to scan (default: \$HOME)"
  echo "  -h        Help"
  echo ""
  echo "Examples:"
  echo "  ./dir_storage.zsh -d /Users/username/Documents -s 50M -L 10"
  echo "  ./dir_storage.zsh -d ~/Downloads -s 1G"
}

while getopts ":s:fL:d:h" opt; do
  case $opt in
    s) MIN_SIZE="$OPTARG" ;;
    f) INCLUDE_FILES=1 ;;
    L) CHILD_LIMIT="$OPTARG" ;;
    d) TARGET_DIR="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Missing arg for -$OPTARG" >&2; exit 1 ;;
    \?) echo "Unknown option -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

# Set target directory to user input or default
if [ -n "$TARGET_DIR" ]; then
  SCAN_DIR="$TARGET_DIR"
else
  echo -n "Enter directory to scan (default: $DEFAULT_DIR): "
  read -r _input_dir
  if [ -n "$_input_dir" ]; then
    # Remove surrounding quotes if present
    _input_dir="${_input_dir#\'}"
    _input_dir="${_input_dir%\'}"
    _input_dir="${_input_dir#\"}"
    _input_dir="${_input_dir%\"}"
    SCAN_DIR="$_input_dir"
  else
    SCAN_DIR="$DEFAULT_DIR"
  fi
fi

# Prompt for MIN_SIZE if not set
if [ -z "$MIN_SIZE" ]; then
  echo -n "Enter minimum file size number (default 100): "
  read -r _num
  [ -z "$_num" ] && _num=100
  echo -n "Enter unit (K/M/G/T) default M: "
  read -r _unit
  _unit=${_unit:u}
  [ -z "$_unit" ] && _unit=M
  case $_unit in K|M|G|T) ;; *) echo "Invalid unit, using M"; _unit=M ;; esac
  MIN_SIZE="${_num}${_unit}"
fi

# Validate directory exists
if [ ! -d "$SCAN_DIR" ]; then
  echo "Directory not found: $SCAN_DIR" >&2
  exit 1
fi

# Remove trailing slash
SCAN_DIR="${SCAN_DIR%/}"

echo "Scanning Directory: $SCAN_DIR"
echo "Minimum file size for files: $MIN_SIZE"
echo "Child limit per directory: $CHILD_LIMIT"

# Function to get human readable size  
get_human_size() {
  local path="$1"
  if [ -d "$path" ] || [ -f "$path" ]; then
    local output=$(du -sh "$path" 2>/dev/null || echo "0B")
    # Extract just the size part (everything before the first tab/space and path)
    echo "$output" | while IFS=$'\t ' read -r size rest; do echo "$size"; break; done
  else
    echo "0B"
  fi
}

# Function to get size in KB for sorting
get_kb_size() {
  local path="$1"
  if [ -d "$path" ] || [ -f "$path" ]; then
    local output=$(du -sk "$path" 2>/dev/null || echo "0")
    # Extract just the size part (everything before the first tab/space and path)
    echo "$output" | while IFS=$'\t ' read -r size rest; do echo "$size"; break; done
  else
    echo "0"
  fi
}

# Function to print directory tree recursively
print_tree() {
  local current_dir="$1"
  local depth="$2"
  local prefix="$3"
  
  # Limit depth to prevent excessive processing
  if [ $depth -gt 3 ]; then
    return
  fi
  
  echo "Processing: $current_dir (depth: $depth)" >&2
  
  # Get immediate subdirectories only
  local subdirs
  subdirs=$(find "$current_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n $CHILD_LIMIT || true)
  
  # Get large files in current directory
  local large_files=""
  if [ $INCLUDE_FILES -eq 1 ]; then
    large_files=$(find "$current_dir" -mindepth 1 -maxdepth 1 -type f -size +$MIN_SIZE 2>/dev/null | head -n $CHILD_LIMIT || true)
  fi
  
  # Combine directories and files with their sizes
  local items=""
  
  # Add directories
  if [ -n "$subdirs" ]; then
    while IFS= read -r subdir; do
      [ -z "$subdir" ] && continue
      local kb_size=$(get_kb_size "$subdir")
      local human_size=$(get_human_size "$subdir")
      local name=$(basename "$subdir")
      items+="D\t$kb_size\t$name\t$human_size\t$subdir"$'\n'
    done <<<"$subdirs"
  fi
  
  # Add files
  if [ -n "$large_files" ]; then
    while IFS= read -r file; do
      [ -z "$file" ] && continue
      if [ -f "$file" ]; then
        local file_size_bytes=$(stat -f %z "$file" 2>/dev/null || echo "0")
        local kb_size=$(((file_size_bytes + 1023)/1024))
        local human_size
        if [ $file_size_bytes -ge 1073741824 ]; then
          # Use shell arithmetic for better compatibility
          local gb_size=$((file_size_bytes / 1073741824))
          local remainder=$((file_size_bytes % 1073741824))
          local decimal=$((remainder * 10 / 1073741824))
          human_size="${gb_size}.${decimal}G"
        elif [ $file_size_bytes -ge 1048576 ]; then
          local mb_size=$((file_size_bytes / 1048576))
          local remainder=$((file_size_bytes % 1048576))
          local decimal=$((remainder * 10 / 1048576))
          human_size="${mb_size}.${decimal}M"
        else
          local kb_size=$((file_size_bytes / 1024))
          human_size="${kb_size}K"
        fi
        local name=$(basename "$file")
        items+="F\t$kb_size\t$name\t$human_size\t$file"$'\n'
      fi
    done <<<"$large_files"
  fi
  
  # Sort items by size (descending) and display
  if [ -n "$items" ]; then
    local sorted_items=$(printf '%b' "$items" | sort -t$'\t' -k2,2nr | head -n $CHILD_LIMIT)
    while IFS=$'\t' read -r type kb_size name human_size full_path; do
      [ -z "$type" ] && continue
      printf '%s├── %s [%s]\n' "$prefix" "$name" "$human_size"
      
      # Recurse into subdirectories
      if [ "$type" = "D" ]; then
        print_tree "$full_path" $((depth + 1)) "$prefix  "
      fi
    done <<<"$sorted_items"
  fi
}

# Print root directory info
root_size=$(get_human_size "$SCAN_DIR")
root_name=$(basename "$SCAN_DIR")
printf '%s [%s]\n' "$root_name" "$root_size"

# Start recursive tree printing
print_tree "$SCAN_DIR" 0 ""

echo "Done."
