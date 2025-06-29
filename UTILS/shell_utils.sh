#!/bin/bash
# ---------------------------------------
# Shell Utility Functions Library
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Common utility functions for shell scripts
#              - print_style: Print formatted messages with borders
#              - mk_log: Print colored messages with optional styling
#              - detect_os: Detect the current operating system
#              - get_linux_distro: Get Linux distribution information
# ---------------------------------------

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
    local GREEN="\033[32m"
    local RED="\033[31m"
    local YELLOW="\033[33m"
    local BLUE="\033[34m"
    local PURPLE="\033[35m"
    local DEFAULT="\033[0m"
    
    # Set the color based on the parameter
    local selected_color="$DEFAULT"
    if [ "$color" == "green" ]; then
        selected_color="$GREEN"
    elif [ "$color" == "red" ]; then
        selected_color="$RED"
    elif [ "$color" == "yellow" ]; then
        selected_color="$YELLOW"
    elif [ "$color" == "blue" ]; then
        selected_color="$BLUE"
    elif [ "$color" == "purple" ]; then
        selected_color="$PURPLE"
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

# Function to detect the current operating system
detect_os() {
    local os_name="unknown"
    
    if [[ "$(uname)" == "Darwin" ]]; then
        os_name="macos"
    elif [[ "$(uname)" == "Linux" ]]; then
        os_name="linux"
    fi
    
    echo "$os_name"
}

# Function to get Linux distribution information
get_linux_distro() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$ID"
    elif [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]'
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/centos-release ]; then
        echo "centos"
    else
        echo "unknown"
    fi
}

# Example of how to use these functions:
# source /path/to/shell_utils.sh
# mk_log "This is a success message" "true" "green"
# mk_log "This is an error message" "true" "red"
# mk_log "This is a plain message" "true"
# os=$(detect_os)
# if [ "$os" == "linux" ]; then
#   distro=$(get_linux_distro)
#   echo "Running on Linux distribution: $distro"
# fi
