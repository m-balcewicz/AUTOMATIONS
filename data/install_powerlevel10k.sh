#!/bin/bash
# ---------------------------------------
# Script: install_powerlevel10k.sh
# Author: Martin Balcewicz
# Date: October 2025
# Description: Installs and configures Powerlevel10k theme for ZSH
# ---------------------------------------

# Get script directory and source utilities
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
UTILS_PATH="${SCRIPT_DIR}/../utils/shell_utils.sh"

# Source utilities if available
if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    # Simple fallback logging function
    mk_log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    }
fi

# Source OS detection
source "$SCRIPT_DIR/detect_os.sh" then
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
Powerlevel10k works best with Oh-My-ZSH.
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

# Check if a Nerd Font is installed
check_nerd_font() {
    # Check in the user's font directory for any Nerd Font
    if find ~/Library/Fonts -name "*Nerd*Font*" -o -name "*nerd*font*" 2>/dev/null | grep -q .; then
        return 0
    fi
    
    # Check in the system font directory for any Nerd Font
    if find /Library/Fonts -name "*Nerd*Font*" -o -name "*nerd*font*" 2>/dev/null | grep -q .; then
        return 0
    fi
    
    mk_log "
No Nerd Font found on your system.
Powerlevel10k requires a Nerd Font to display special characters correctly.
" "true" "red"
    
    read -p "Would you like to install JetBrains Mono Nerd Font now? (y/n): " install_font
    if [[ "$install_font" =~ ^[Yy]$ ]]; then
        # Check if the JetBrains Mono Nerd Font installer script exists
        local font_installer="/Users/martin/Data/CODING_WORLD/AUTOMATIONS/TOOLS/install_jetbrains_mono_nerd_font.sh"
        if [ -f "$font_installer" ]; then
            mk_log "Running JetBrains Mono Nerd Font installer..." "false" "green"
            bash "$font_installer"
            return $?
        else
            mk_log "
JetBrains Mono Nerd Font installer not found at:
$font_installer

Please install a Nerd Font manually and then run this script again.
" "true" "red"
            exit 1
        fi
    else
        mk_log "
Cannot proceed without a Nerd Font. 
Powerlevel10k will not display correctly without one.
" "true" "red"
        
        read -p "Do you want to proceed anyway? (y/n): " proceed_anyway
        if [[ "$proceed_anyway" =~ ^[Yy]$ ]]; then
            return 0
        else
            exit 1
        fi
    fi
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

# Function to install Powerlevel10k
install_powerlevel10k() {
    mk_log "Installing Powerlevel10k theme..." "false" "green"
    
    # Check if powerlevel10k is already installed
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        mk_log "
Powerlevel10k theme is already installed.
Checking configuration...
" "false" "green"
        
        # Update the repository to get the latest version
        mk_log "Updating Powerlevel10k to the latest version..." "false" "green"
        cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" && git pull
    else
        # Install Powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
        
        if [ $? -ne 0 ]; then
            mk_log "
Failed to install Powerlevel10k.
Please check your internet connection and try again.
" "true" "red"
            return 1
        fi
    fi
    
    # Set Powerlevel10k as the ZSH theme
    if ! grep -q "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" "$HOME/.zshrc"; then
        mk_log "Setting Powerlevel10k as the default ZSH theme..." "false" "green"
        # Find the current ZSH_THEME line and replace it
        if grep -q "ZSH_THEME=" "$HOME/.zshrc"; then
            sed -i '' 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        else
            # If no ZSH_THEME line is found, add it
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
        fi
    else
        mk_log "Powerlevel10k is already set as the default theme." "false" "green"
    fi
    
    return 0
}

# Display welcome message
echo -e "\033[32m----------------------------------"
echo -e "Welcome to Powerlevel10k Installer"
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)"
echo -e "----------------------------------\033[0m"
echo ""

# Check prerequisites
check_macos
check_zsh
check_oh_my_zsh
check_nerd_font

# Install/update Powerlevel10k
if install_powerlevel10k; then
    mk_log "
Powerlevel10k has been successfully installed!

NEXT STEPS:
1. Close this terminal window completely
2. Open a new terminal window
3. The Powerlevel10k configuration wizard will start automatically
4. Follow the prompts to customize your terminal appearance:
   - Answer 'y' when asked if your terminal shows Nerd Font icons correctly
   - Choose your preferred style, colors, and prompt segments

If the wizard doesn't start automatically, run:
p10k configure
" "true" "green"
else
    mk_log "
Something went wrong with the Powerlevel10k installation.
Please try again or install manually:

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo 'ZSH_THEME=\"powerlevel10k/powerlevel10k\"' >> ~/.zshrc
" "true" "red"
    exit 1
fi

echo ""
echo -e "\033[32m----------------------------------"
echo -e "Powerlevel10k Setup Complete!"
echo -e "----------------------------------\033[0m"
echo ""
