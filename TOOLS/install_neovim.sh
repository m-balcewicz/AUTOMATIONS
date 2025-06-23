#!/bin/bash
# ---------------------------------------
# Script: install_neovim.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Installs or updates Neovim editor
#              using Homebrew package manager
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

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        mk_log "This script is for macOS only. Exiting." "false" "red"
        exit 1
    fi
}

# Check if Homebrew is installed
check_brew_installed() {
    if command -v brew &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if Neovim is already installed
check_neovim_installed() {
    if command -v nvim &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Neovim using Homebrew
install_neovim() {
    mk_log "Installing Neovim..." "false" "green"
    brew install neovim
    
    # Check if installation was successful
    if check_neovim_installed; then
        return 0
    else
        return 1
    fi
}

# Create Neovim configuration directories if they don't exist
setup_neovim_config() {
    local config_dir="$HOME/.config/nvim"
    
    if [ ! -d "$config_dir" ]; then
        mk_log "Creating Neovim configuration directory..." "false" "green"
        mkdir -p "$config_dir"
        
        # Create a basic init.vim file
        echo "\" Basic Neovim Configuration" > "$config_dir/init.vim"
        echo "set number          \" Show line numbers" >> "$config_dir/init.vim"
        echo "set expandtab       \" Use spaces instead of tabs" >> "$config_dir/init.vim"
        echo "set tabstop=4       \" Number of spaces tabs count for" >> "$config_dir/init.vim"
        echo "set shiftwidth=4    \" Size of an indent" >> "$config_dir/init.vim"
        echo "set autoindent      \" Enable auto indentation" >> "$config_dir/init.vim"
        echo "set smartindent     \" Enable smart indentation" >> "$config_dir/init.vim"
        echo "set cursorline      \" Highlight current line" >> "$config_dir/init.vim"
        echo "syntax on           \" Enable syntax highlighting" >> "$config_dir/init.vim"
        
        mk_log "Created basic Neovim configuration file at $config_dir/init.vim" "false" "green"
    else
        mk_log "Neovim configuration directory already exists at $config_dir" "false" "green"
    fi
}

# Display welcome message
echo -e "\033[32m----------------------------------"
echo -e "Welcome to Neovim Installer"
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)"
echo -e "----------------------------------\033[0m"
echo ""

# Check if running on macOS
check_macos

# Check if Homebrew is installed
if ! check_brew_installed; then
    mk_log "
Homebrew is required but not installed!

Please install Homebrew first using the install_brew.sh script:
./install_brew.sh
" "true" "red"
    exit 1
fi

# Check if Neovim is already installed
if check_neovim_installed; then
    mk_log "
Neovim is already installed!

Current version:
$(nvim --version | head -n 1)
" "true" "green"
    
    # Ask if user wants to update
    read -p "Do you want to update Neovim? (y/n): " update_choice
    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
        mk_log "Updating Neovim..." "false" "green"
        brew upgrade neovim
        mk_log "
Neovim has been updated!

Current version:
$(nvim --version | head -n 1)
" "true" "green"
    fi
    
    # Ask if user wants to set up or reset Neovim configuration
    read -p "Do you want to set up/reset basic Neovim configuration? (y/n): " config_choice
    if [[ "$config_choice" =~ ^[Yy]$ ]]; then
        setup_neovim_config
    fi
else
    # Ask user if they want to install Neovim
    read -p "Neovim is not installed. Do you want to install it now? (y/n): " install_choice
    
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        if install_neovim; then
            mk_log "
Neovim has been successfully installed!

Current version:
$(nvim --version | head -n 1)
" "true" "green"
            
            # Set up basic Neovim configuration
            setup_neovim_config
        else
            mk_log "
Failed to install Neovim. Please try again or install manually:
brew install neovim
" "true" "red"
            exit 1
        fi
    else
        mk_log "Installation cancelled by user." "false" "red"
        exit 0
    fi
fi

# Show a list of useful Neovim commands
mk_log "
Useful Neovim Commands:
- nvim <filename>     : Open a file in Neovim
- :q                  : Quit
- :w                  : Save
- :wq                 : Save and quit
- :q!                 : Quit without saving
- i                   : Enter insert mode
- Esc                 : Return to normal mode
- :help               : Get help
" "true" "green"

echo ""
echo -e "\033[32m----------------------------------"
echo -e "Neovim Setup Complete!"
echo -e "----------------------------------\033[0m"
echo ""
