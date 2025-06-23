#!/bin/bash
# ---------------------------------------
# Script: install_zsh_autocompletion.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Installs useful ZSH autocompletion plugins
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

# Check if ZSH is the current shell
check_zsh() {
    if [[ "$SHELL" != */zsh ]]; then
        mk_log "
ZSH is not your current shell.
Please run install_zsh.sh first to switch to ZSH.
" "true" "red"
        exit 1
    fi
    return 0
}

# Check if Oh-My-ZSH is installed
check_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        mk_log "
Oh-My-ZSH is not installed.
The autocompletion plugins work best with Oh-My-ZSH.
" "true" "red"
        
        read -p "Would you like to install Oh-My-ZSH now? (y/n): " install_omz
        if [[ "$install_omz" =~ ^[Yy]$ ]]; then
            install_oh_my_zsh
            return $?
        else
            mk_log "Cannot proceed without Oh-My-ZSH. Exiting." "false" "red"
            exit 1
        fi
    fi
    return 0
}

# Function to install Oh-My-ZSH
install_oh_my_zsh() {
    mk_log "Installing Oh-My-ZSH..." "false" "green"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    local install_status=$?
    if [ $install_status -eq 0 ]; then
        mk_log "Oh-My-ZSH installed successfully!" "false" "green"
        return 0
    else
        mk_log "
Failed to install Oh-My-ZSH.
Please install it manually with:
sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"
" "true" "red"
        return 1
    fi
}

# Install zsh-autosuggestions plugin
install_autosuggestions() {
    local custom_plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # Check if the plugin is already installed
    if [ -d "$custom_plugins_dir/zsh-autosuggestions" ]; then
        mk_log "zsh-autosuggestions plugin is already installed." "false" "green"
        # Update the plugin
        mk_log "Updating zsh-autosuggestions..." "false" "green"
        cd "$custom_plugins_dir/zsh-autosuggestions" && git pull
    else
        # Install the plugin
        mk_log "Installing zsh-autosuggestions plugin..." "false" "green"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_plugins_dir/zsh-autosuggestions"
        
        if [ $? -ne 0 ]; then
            mk_log "Failed to install zsh-autosuggestions plugin." "false" "red"
            return 1
        fi
    fi
    
    return 0
}

# Install zsh-syntax-highlighting plugin
install_syntax_highlighting() {
    local custom_plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # Check if the plugin is already installed
    if [ -d "$custom_plugins_dir/zsh-syntax-highlighting" ]; then
        mk_log "zsh-syntax-highlighting plugin is already installed." "false" "green"
        # Update the plugin
        mk_log "Updating zsh-syntax-highlighting..." "false" "green"
        cd "$custom_plugins_dir/zsh-syntax-highlighting" && git pull
    else
        # Install the plugin
        mk_log "Installing zsh-syntax-highlighting plugin..." "false" "green"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_plugins_dir/zsh-syntax-highlighting"
        
        if [ $? -ne 0 ]; then
            mk_log "Failed to install zsh-syntax-highlighting plugin." "false" "red"
            return 1
        fi
    fi
    
    return 0
}

# Configure plugins in .zshrc - fixed to prevent duplicates
configure_plugins() {
    # Check if plugins are already configured
    if grep -q "zsh-autosuggestions" "$HOME/.zshrc" && grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
        mk_log "Plugins are already configured in .zshrc" "false" "green"
        return 0
    fi
    
    # Find the plugins line in .zshrc
    if grep -q "^plugins=(" "$HOME/.zshrc"; then
        # First, make a backup of the original .zshrc file
        cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
        
        # Extract current plugins from the first plugins line
        local current_line=$(grep "^plugins=(" "$HOME/.zshrc" | head -n 1)
        local current_plugins=$(echo "$current_line" | sed 's/plugins=(//' | sed 's/).*//')
        
        # Create a clean list of current plugins (no duplicates)
        local plugin_list=()
        for plugin in $current_plugins; do
            # Only add if not already in the list
            if ! echo "${plugin_list[*]}" | grep -q "$plugin"; then
                plugin_list+=("$plugin")
            fi
        done
        
        # Add the new plugins if not already in the list
        if ! echo "${plugin_list[*]}" | grep -q "zsh-autosuggestions"; then
            plugin_list+=("zsh-autosuggestions")
        fi
        
        if ! echo "${plugin_list[*]}" | grep -q "zsh-syntax-highlighting"; then
            plugin_list+=("zsh-syntax-highlighting")
        fi
        
        # Create the new plugins line
        local new_plugins_line="plugins=(${plugin_list[*]})"
        
        # Replace the first plugins line in .zshrc
        awk -v new_line="$new_plugins_line" '
        {
            if ($0 ~ /^plugins=\(/ && !replaced) {
                print new_line;
                replaced = 1;
            } else if ($0 ~ /^plugins=\(/ && replaced) {
                # Skip additional plugin lines
            } else {
                print $0;
            }
        }' "$HOME/.zshrc.bak" > "$HOME/.zshrc"
        
    else
        # No plugins line found, add one
        echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> "$HOME/.zshrc"
    fi
    
    mk_log "Plugins configured successfully in .zshrc" "false" "green"
    return 0
}

# Display welcome message
echo -e "\033[32m----------------------------------"
echo -e "Welcome to ZSH Autocompletion Installer"
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)"
echo -e "----------------------------------\033[0m"
echo ""

# Check prerequisites
check_zsh
check_oh_my_zsh

# Install and configure plugins with more detailed header
echo -e "\033[32m----------------------------------"
echo -e "ZSH Plugins Installation"
echo -e "----------------------------------\033[0m"
echo ""
echo -e "This script will install/update the following plugins:"
echo ""
echo -e "\033[32m1. zsh-autosuggestions\033[0m"
echo -e "   • Source: https://github.com/zsh-users/zsh-autosuggestions"
echo -e "   • Features: Shows command suggestions as you type"
echo -e "   • Install path: ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
echo ""
echo -e "\033[32m2. zsh-syntax-highlighting\033[0m"
echo -e "   • Source: https://github.com/zsh-users/zsh-syntax-highlighting"
echo -e "   • Features: Highlights commands in real-time"
echo -e "   • Install path: ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
echo ""
echo -e "\033[32m----------------------------------\033[0m"
echo ""

# Install zsh-autosuggestions
install_autosuggestions
# Install zsh-syntax-highlighting
install_syntax_highlighting
# Configure plugins in .zshrc
configure_plugins

# Show completion message
mk_log "
ZSH Autocompletion Plugins have been installed!

These plugins provide:
- zsh-autosuggestions: Shows grey suggestions based on your command history
- zsh-syntax-highlighting: Highlights commands in different colors

NEXT STEPS:
1. Close this terminal window completely
2. Open a new terminal window to activate the plugins

USAGE TIPS:
- For autosuggestions: Type a command and press → (right arrow) to accept suggestion
- Correct commands will be highlighted in green
- Invalid commands will be highlighted in red

You can customize these plugins in your ~/.zshrc file.
" "true" "green"

echo ""
echo -e "\033[32m----------------------------------"
echo -e "ZSH Autocompletion Setup Complete!"
echo -e "----------------------------------\033[0m"
echo ""
