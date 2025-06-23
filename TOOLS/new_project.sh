#!/bin/bash
# ---------------------------------------
# Script: new_project.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Creates a new project directory structure
#              with standard folders for organization
# ---------------------------------------

# Source the shell utilities
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
UTILS_PATH="${SCRIPT_DIR}/../UTILS/shell_utils.sh"

# Source the utilities file or use local fallback implementations
if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    echo "Warning: Could not find shell utilities at $UTILS_PATH"
    echo "Using local function implementations instead."
    
    # Local fallback implementations of utility functions
    print_style() {
        local message="$1"
        local style="${2:-indented_separator}"
        
        # Determine the style character
        local style_chars="-"
        if [ "$style" == "box" ]; then
            style_chars="#"
        elif [ "$style" == "section" ]; then
            style_chars="="
        elif [ "$style" == "decorative" ]; then
            style_chars="*"
        fi
        
        # Find the maximum line length
        local max_length=0
        while IFS= read -r line; do
            # Strip ANSI color codes when calculating length
            local stripped_line=$(echo -e "$line" | sed 's/\x1b\[[0-9;]*m//g')
            if [ ${#stripped_line} -gt $max_length ]; then
                max_length=${#stripped_line}
            fi
        done <<< "$message"
        
        # Print the style line
        echo -e "$(printf "%${max_length}s" | tr ' ' "$style_chars")"
        
        # Print each line of the message
        while IFS= read -r line; do
            echo -e "$line"
        done <<< "$message"
        
        # Print the bottom style line
        echo -e "$(printf "%${max_length}s" | tr ' ' "$style_chars")"
    }

    mk_log() {
        local message="$1"
        local print_fancy="${2:-false}"
        local color="${3:-default}"
        
        # Define ANSI color codes
        local GREEN="\033[32m"  
        local RED="\033[31m"    
        local DEFAULT="\033[0m"
        
        # Set the color based on the parameter
        local selected_color="$DEFAULT"
        if [ "$color" == "green" ]; then
            selected_color="$GREEN"
        elif [ "$color" == "red" ]; then
            selected_color="$RED"
        fi
        
        # Apply color to each line
        local colored_message=""
        while IFS= read -r line; do
            # Add color to each non-empty line
            if [ -n "$line" ]; then
                colored_message+="${selected_color}${line}${DEFAULT}\n"
            else
                colored_message+="\n"
            fi
        done <<< "$message"
        
        # Print the message with optional fancy formatting
        if [ "$print_fancy" == "true" ]; then
            echo -e "$colored_message" | while IFS= read -r line; do
                echo -e "$line"
            done | print_style
        else
            echo -e "$colored_message"
        fi
    }
fi

# Function to create directories
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created directory: $1"
    else
        echo "Directory already exists: $1"
    fi
}

# Display the welcome message using mk_log instead of direct ANSI codes
mk_log "
Welcome to New Project Script.
Developed 06/2025 by Martin Balcewicz
(mail: martin.balcewicz@rockphysics.org).
" "true" "green"

# Get current date and time
current_datetime=$(date '+%Y-%m-%d, %H:%M:%S')

# Prompt for project ID
read -p "Enter project ID: " project_id

# Prompt for project path
read -p "Enter project path: " project_path

# Validate inputs
if [ -z "$project_id" ] || [ -z "$project_path" ]; then
    mk_log "Invalid input. Both project ID and path are required." "false" "red"
    exit 1
fi

# Create full path
full_path="$project_path/$project_id"

# Create main project directory
create_directory "$full_path"

# Create system folders
folders=(".vscode" "00_Administration" "01_Code" "02_Data" "03_Manuscript" "04_Presentation")
for folder in "${folders[@]}"; do
    create_directory "$full_path/$folder"
done

# Show completion message using mk_log instead of direct ANSI codes
mk_log "
Project setup complete!
Project ID: $project_id
Project Path: $project_path
Full Path: $full_path
" "true" "green"