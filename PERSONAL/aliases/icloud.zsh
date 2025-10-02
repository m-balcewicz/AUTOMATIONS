#!/bin/zsh
# Fixed and optimized version - use the icloud_simple.zsh for better performance
# This version has been fixed but the simple version is recommended

# NOTE: This script had performance issues with large directory trees.
# Use icloud_simple.zsh instead for better performance and reliability.

echo "This script has been superseded by icloud_simple.zsh"
echo "Please use: ./icloud_simple.zsh instead"
exit 1

set -euo pipefail

# ICLOUD_DIR="${ICLOUD_DIR:-$HOME/Library/Mobile Documents/com~apple~CloudDocs}"
ICLOUD_DIR="${ICLOUD_DIR:-$HOME/Library/Mobile Documents/com~apple~CloudDocs/MYDATA}"
DIR_OF_INTEREST=""

MIN_SIZE="${MIN_SIZE:-}"   # if empty we'll prompt
INCLUDE_FILES=1
CHILD_LIMIT=20

usage(){
  sed -n '2,22p' "$0"
  echo "  -d DIR    Directory to scan (default: iCloud Drive at $HOME/Library/Mobile Documents/com~apple~CloudDocs)"
}

while getopts ":s:fL:d:h" opt; do
  case $opt in
    s) MIN_SIZE="$OPTARG" ;;
    f) INCLUDE_FILES=1 ;;
    L) CHILD_LIMIT="$OPTARG" ;;
    d) DIR_OF_INTEREST="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Missing arg for -$OPTARG" >&2; exit 1 ;;
    \?) echo "Unknown option -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

# Set ICLOUD_DIR to user input or default
if [ -n "$DIR_OF_INTEREST" ]; then
  ICLOUD_DIR="$DIR_OF_INTEREST"
else
  echo -n "Enter directory to scan (default: $ICLOUD_DIR): "
  read -r _input_dir
  if [ -n "$_input_dir" ]; then
    # Remove surrounding quotes if present
    _input_dir="${_input_dir#\'}"  # Remove leading single quote
    _input_dir="${_input_dir%\'}"  # Remove trailing single quote
    _input_dir="${_input_dir#\"}"  # Remove leading double quote
    _input_dir="${_input_dir%\"}"  # Remove trailing double quote
    ICLOUD_DIR="$_input_dir"
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

if [ ! -d "$ICLOUD_DIR" ]; then
  echo "iCloud Drive folder not found: $ICLOUD_DIR" >&2
  exit 1
fi

ICLOUD_DIR="${ICLOUD_DIR%/}"

echo "Scanning iCloud Drive: $ICLOUD_DIR"
echo "Minimum file size for files: $MIN_SIZE"

echo "icloud"

# Gather directories (limited depth for performance)
DIR_LIST=$(find "$ICLOUD_DIR" -type d -maxdepth 4 -print)

# Optionally gather files (>= MIN_SIZE, limited depth)
if [ $INCLUDE_FILES -eq 1 ]; then
  FILE_LIST=$(find "$ICLOUD_DIR" -type f -maxdepth 4 -size +$MIN_SIZE -print || true)
else
  FILE_LIST=""
fi

# Associative arrays for sizes (human + KB numeric)
typeset -A DIR_SIZE_HUMAN DIR_SIZE_KB FILE_SIZE_HUMAN FILE_SIZE_KB

calc_dir_size(){
  local d="$1"
  if [[ -z "${DIR_SIZE_KB[$d]:-}" ]]; then
    local kb human
    kb=$(du -sk "$d" 2>/dev/null | awk '{print $1}') || kb=0
    human=$(du -sh "$d" 2>/dev/null | awk '{print $1}') || human="?"
    DIR_SIZE_KB[$d]="$kb"
    DIR_SIZE_HUMAN[$d]="$human"
  fi
}

calc_file_size(){
  local f="$1"
  if [[ -z "${FILE_SIZE_KB[$f]:-}" ]]; then
    local bytes kb human
    if bytes=$(stat -f %z "$f" 2>/dev/null); then
      kb=$(((bytes + 1023)/1024))
      local val=$bytes
      if [ $val -ge 1099511627776 ]; then
        human=$(printf '%.1fT' "$(echo "$val/1099511627776" | bc -l)")
      elif [ $val -ge 1073741824 ]; then
        human=$(printf '%.1fG' "$(echo "$val/1073741824" | bc -l)")
      elif [ $val -ge 1048576 ]; then
        human=$(printf '%.1fM' "$(echo "$val/1048576" | bc -l)")
      elif [ $val -ge 1024 ]; then
        human=$(printf '%.1fK' "$(echo "$val/1024" | bc -l)")
      else
        human="${val}B"
      fi
    else
      kb=0
      human="?"
    fi
    FILE_SIZE_KB[$f]="$kb"
    FILE_SIZE_HUMAN[$f]="$human"
  fi
}

# Pre-calc directory sizes
while IFS= read -r d; do
  [ -n "$d" ] && calc_dir_size "$d"
done <<<"$DIR_LIST"

# Pre-calc file sizes
if [ -n "$FILE_LIST" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] && calc_file_size "$f"
  done <<<"$FILE_LIST"
fi

# Build parent -> children maps - Only process direct children  
typeset -A CHILD_DIRS CHILD_FILES
echo "DEBUG: Building child directory maps with depth limit..." >&2

# Build parent-child relationships more efficiently
# Only map directories up to a certain depth to avoid performance issues
while IFS= read -r d; do
  [ -z "$d" ] && continue
  rel="${d#${ICLOUD_DIR}/}"
  [ "$rel" = "$d" ] && continue
  
  # Count directory depth
  depth_count=$(echo "$rel" | tr -cd '/' | wc -c)
  depth_count=$((depth_count + 1))
  
  # Skip very deep directories to improve performance
  if [ $depth_count -gt 4 ]; then
    continue
  fi
  
  # Get the parent directory
  parent_rel="${rel%/*}"
  if [[ "$rel" == */* ]]; then
    parent_abs="$ICLOUD_DIR/${parent_rel}"
  else
    parent_abs="$ICLOUD_DIR"
  fi
  
  CHILD_DIRS[$parent_abs]="${CHILD_DIRS[$parent_abs]-}$d"$'\n'
  calc_dir_size "$d"
done <<<"$DIR_LIST"

echo "DEBUG: Mapped ${#CHILD_DIRS[@]} parent directories" >&2

if [ -n "$FILE_LIST" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#${ICLOUD_DIR}/}"
    parent_rel="${rel%/*}"
    if [[ "$rel" == */* ]]; then
      parent_abs="$ICLOUD_DIR/${parent_rel}"
    else
      parent_abs="$ICLOUD_DIR"
    fi
    CHILD_FILES[$parent_abs]="${CHILD_FILES[$parent_abs]-}$f"$'\n'
    calc_file_size "$f"
  done <<<"$FILE_LIST"
fi

# Check for required tools
for tool in awk sort grep; do
  if ! command -v $tool >/dev/null 2>&1; then
    echo "Error: Required tool '$tool' not found in PATH. Please install it (e.g. via Homebrew: brew install $tool)" >&2
    exit 1
  fi
done

# Recursive print limited children
print_dir(){
  local dir="$1" depth="$2"
  
  # Limit recursion depth to prevent infinite loops and excessive processing
  if [ $depth -gt 5 ]; then
    echo "  (max depth reached)" >&2
    return
  fi
  
  echo "DEBUG: Processing directory: $dir (depth: $depth)" >&2
  
  local awk_bin sort_bin
  awk_bin=$(command -v awk)
  sort_bin=$(command -v sort)
  
  local lines=""
  
  # Process directories
  if [[ -n "${CHILD_DIRS[$dir]-}" ]]; then
    echo "DEBUG: Found child directories for $dir" >&2
    local child_count=0
    while IFS= read -r child; do
      [ -z "$child" ] && continue
      child_count=$((child_count + 1))
      
      # Limit processing if too many children (performance)
      if [ $child_count -gt 100 ]; then
        echo "DEBUG: Too many children, limiting to first 100" >&2
        break
      fi
      
      if [ ! -d "$child" ]; then
        continue
      fi
      local kb="${DIR_SIZE_KB[$child]:-0}" human="${DIR_SIZE_HUMAN[$child]:-?}"
      lines+="D\t$child\t$kb\t$human"$'\n'
    done <<<"${CHILD_DIRS[$dir]}"
  else
    echo "DEBUG: No child directories found for $dir" >&2
  fi
  
  # Process files
  if [ $INCLUDE_FILES -eq 1 ] && [[ -n "${CHILD_FILES[$dir]-}" ]]; then
    while IFS= read -r child; do
      [ -z "$child" ] && continue
      local kb="${FILE_SIZE_KB[$child]:-0}" human="${FILE_SIZE_HUMAN[$child]:-?}"
      lines+="F\t$child\t$kb\t$human"$'\n'
    done <<<"${CHILD_FILES[$dir]}"
  fi
  
  if [ -z "$lines" ]; then
    return
  fi
  local sorted=$(printf '%b' "$lines" | "$awk_bin" -F '\t' 'NF==4 {print}' | "$sort_bin" -k3,3nr)
  
  if [ -z "$sorted" ]; then
    return
  fi
  
  local count=0
  while IFS=$'\t' read -r typ path kb human; do
    [ -z "$typ" ] && continue
    count=$((count+1))
    [ $count -gt $CHILD_LIMIT ] && break
    local rel="${path#${ICLOUD_DIR}/}"
    local depth_count=$("$awk_bin" -F'/' '{print NF-1}' <<<"$rel")
    local prefix=""
    local i=0
    while [ $i -lt $depth_count ]; do 
      prefix+="  "
      i=$((i+1))
    done
    local name="${rel##*/}"
    printf '%s├── %s [%s]\n' "$prefix" "$name" "$human"
    
    if [ "$typ" = "D" ]; then
      print_dir "$path" $((depth+1))
    fi
  done <<<"$sorted"
}

# Print root and start recursive display
root_size="${DIR_SIZE_HUMAN[$ICLOUD_DIR]:-?}"
printf 'MYDATA [%s]\n' "$root_size"

# Start recursive display from root
print_dir "$ICLOUD_DIR" 0

echo "\nDone."
