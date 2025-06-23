#!/bin/bash

# Function to print with style
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

# Function to print messages with optional style and color
mk_log() {
    local message="$1"
    local print_fancy="${2:-false}"
    local color="${3:-default}"
    
    # Define ANSI color codes
    local GREEN="\033[32m"  # Changed to standard green
    local RED="\033[31m"    # Changed to standard red
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

# Function to create directories
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created directory: $1"
    else
        echo "Directory already exists: $1"
    fi
}


# Display the welcome message with simpler approach first
echo -e "\033[32m----------------------------------"
echo -e "Welcome to New Project Script."
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)."
echo -e "----------------------------------\033[0m"
echo ""  # Add a blank line after the message

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

# Show completion message using direct approach (like the welcome message)
echo ""  # Add a blank line before the message
echo -e "\033[32m----------------------------------"
echo -e "Project setup complete!"
echo -e "Project ID: $project_id"
echo -e "Project Path: $project_path"
echo -e "Full Path: $full_path"
echo -e "----------------------------------\033[0m"
echo ""  # Add a blank line after the message