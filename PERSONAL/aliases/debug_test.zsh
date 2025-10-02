#!/bin/zsh
# Simple test version to debug the issue

set -euo pipefail

SCAN_DIR="$1"
echo "Testing directory: $SCAN_DIR"

# Test the size functions
echo "Testing get_human_size function..."
get_human_size() {
  local path="$1"
  echo "Checking path: $path" >&2
  if [ -d "$path" ] || [ -f "$path" ]; then
    local size_output
    size_output=$(du -sh "$path" 2>/dev/null)
    echo "Raw du output: '$size_output'" >&2
    if [ $? -eq 0 ] && [ -n "$size_output" ]; then
      local result=$(echo "$size_output" | cut -f1 -d$'\t')
      echo "Cut result: '$result'" >&2
      echo "$result"
    else
      echo "0B"
    fi
  else
    echo "0B"
  fi
}

echo "Root size: $(get_human_size "$SCAN_DIR")"

echo "Testing find command..."
subdirs=$(find "$SCAN_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n 3)
echo "Found subdirs:"
echo "$subdirs"

echo "Testing size calculation for each subdir..."
while IFS= read -r subdir; do
  [ -z "$subdir" ] && continue
  echo "Subdir: $subdir"
  echo "Size: $(get_human_size "$subdir")"
done <<<"$subdirs"

echo "Test complete."
