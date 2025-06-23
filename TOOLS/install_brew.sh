#!/bin/bash
# ---------------------------------------
# Script: install_brew.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Installs or updates Homebrew package manager
#              for macOS systems
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

# Check if Homebrew is already installed
check_brew_installed() {
    if command -v brew &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Homebrew
install_homebrew() {
    mk_log "Installing Homebrew..." "false" "green"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Check if installation was successful
    if check_brew_installed; then
        return 0
    else
        return 1
    fi
}

# Function to detect current shell
get_current_shell() {
    echo "$SHELL"
}

# Function to configure Homebrew for the current shell
configure_brew_for_shell() {
    local current_shell=$(get_current_shell)
    local homebrew_prefix=""
    
    # Determine Homebrew prefix based on architecture
    if [[ $(uname -m) == "arm64" ]]; then
        homebrew_prefix="/opt/homebrew"
    else
        homebrew_prefix="/usr/local"
    fi
    
    echo "Configuring Homebrew for: $current_shell"
    
    if [[ "$current_shell" == */zsh ]]; then
        # Configure for ZSH
        if ! grep -q "eval \"\$($homebrew_prefix/bin/brew shellenv)\"" ~/.zprofile 2>/dev/null; then
            echo "Adding Homebrew to your ZSH profile..."
            echo "eval \"\$($homebrew_prefix/bin/brew shellenv)\"" >> ~/.zprofile
            echo "Homebrew configured in ~/.zprofile"
            
            # Check if Oh-My-ZSH is installed
            if [ -d "$HOME/.oh-my-zsh" ]; then
                echo "Oh-My-ZSH detected, ensuring brew plugin is enabled..."
                # Add brew plugin if not present
                if ! grep -q "plugins=.*brew" ~/.zshrc 2>/dev/null; then
                    sed -i '' 's/plugins=(/plugins=(brew /' ~/.zshrc
                    echo "Enabled brew plugin in Oh-My-ZSH"
                else
                    echo "Brew plugin already enabled in Oh-My-ZSH"
                fi
            fi
        else
            echo "Homebrew is already configured in your ZSH profile"
        fi
        
        # Apply the changes immediately
        eval "$($homebrew_prefix/bin/brew shellenv)"
        
    elif [[ "$current_shell" == */bash ]]; then
        # Configure for Bash
        if ! grep -q "eval \"\$($homebrew_prefix/bin/brew shellenv)\"" ~/.bash_profile 2>/dev/null; then
            echo "Adding Homebrew to your Bash profile..."
            echo "eval \"\$($homebrew_prefix/bin/brew shellenv)\"" >> ~/.bash_profile
            echo "Homebrew configured in ~/.bash_profile"
        else
            echo "Homebrew is already configured in your Bash profile"
        fi
        
        # Apply the changes immediately
        eval "$($homebrew_prefix/bin/brew shellenv)"
        
    else
        echo "Unsupported shell: $current_shell"
        echo "Please manually add Homebrew to your shell profile:"
        echo "echo 'eval \"\$($homebrew_prefix/bin/brew shellenv)\"' >> <your-shell-profile>"
    fi
}

# Display welcome message
echo -e "\033[32m----------------------------------"
echo -e "Welcome to Homebrew Installer"
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)"
echo -e "----------------------------------\033[0m"
echo ""

# Check if running on macOS
check_macos

# Check if Homebrew is already installed
if check_brew_installed; then
    mk_log "
Homebrew is already installed!

Current version:
$(brew --version)
" "true" "green"
    
    # Ask if user wants to update
    read -p "Do you want to update Homebrew? (y/n): " update_choice
    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
        mk_log "Updating Homebrew..." "false" "green"
        brew update
        brew upgrade
        mk_log "
Homebrew has been updated!

Current version:
$(brew --version)
" "true" "green"
    fi
    
    # Ask if user wants to configure Homebrew for their current shell
    read -p "Do you want to configure Homebrew for your current shell? (y/n): " config_choice
    if [[ "$config_choice" =~ ^[Yy]$ ]]; then
        configure_brew_for_shell
    fi
    
else
    # Ask user if they want to install Homebrew
    read -p "Homebrew is not installed. Do you want to install it now? (y/n): " install_choice
    
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        if install_homebrew; then
            mk_log "
Homebrew has been successfully installed!

Installation and configuration complete!
You may need to restart your terminal for changes to take effect.
" "true" "green"
            
            # Configure Homebrew for the current shell
            configure_brew_for_shell
        else
            mk_log "
Failed to install Homebrew. Please try again or install manually:
/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
" "true" "red"
            exit 1
        fi
    else
        mk_log "Installation cancelled by user." "false" "red"
        exit 0
    fi
fi

# Show a list of useful Homebrew commands
mk_log "
Useful Homebrew Commands:
- brew install <package>   : Install a package
- brew uninstall <package> : Remove a package
- brew update              : Update Homebrew
- brew upgrade             : Upgrade all packages
- brew list                : List installed packages
- brew search <term>       : Search for packages
" "true" "green"

echo ""
echo -e "\033[32m----------------------------------"
echo -e "Homebrew Setup Complete!"
echo -e "----------------------------------\033[0m"
echo ""
