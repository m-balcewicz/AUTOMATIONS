#!/bin/bash
# ---------------------------------------
# Script: demo_utils.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Demonstrates the usage of shell utility functions
# ---------------------------------------

# Source the shell utilities - relative path reference
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
UTILS_PATH="${SCRIPT_DIR}/shell_utils.sh"

if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    echo "Error: Could not find shell utilities at $UTILS_PATH"
    echo "Please ensure shell_utils.sh exists in the same directory."
    exit 1
fi

# Display welcome message
echo -e "\033[32m----------------------------------"
echo -e "Shell Utilities Demo"
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)"
echo -e "----------------------------------\033[0m"
echo ""

# Demo of mk_log with different parameters
echo "Demo 1: Green success message with fancy border"
mk_log "
This is a success message!
It can span multiple lines
and will be displayed with a green color.
" "true" "green"

echo "Demo 2: Red error message with fancy border"
mk_log "
This is an error message!
It can span multiple lines
and will be displayed with a red color.
" "true" "red"

echo "Demo 3: Default color message with fancy border"
mk_log "
This is a default color message!
It can span multiple lines
and will be displayed with the default terminal color.
" "true"

echo "Demo 4: Green message without fancy border"
mk_log "This is a simple green message without fancy border." "false" "green"

echo "Demo 5: Red message without fancy border"
mk_log "This is a simple red message without fancy border." "false" "red"

echo "Demo 6: Default color message without fancy border"
mk_log "This is a simple default color message without fancy border." "false"

# Demo of different print_style border styles
echo ""
echo "Demo of different border styles:"
echo ""

echo "Style: indented_separator (default)"
print_style "This is the default border style\nIt uses dashes as separators"

echo ""
echo "Style: box"
print_style "This is the box border style\nIt uses hash symbols as separators" "box"

echo ""
echo "Style: section"
print_style "This is the section border style\nIt uses equal signs as separators" "section"

echo ""
echo "Style: decorative"
print_style "This is the decorative border style\nIt uses asterisks as separators" "decorative"

echo ""
echo -e "\033[32m----------------------------------"
echo -e "Demo Complete!"
echo -e "----------------------------------\033[0m"
echo ""
