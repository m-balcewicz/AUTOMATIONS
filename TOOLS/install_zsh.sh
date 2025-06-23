#!/bin/bash
# ---------------------------------------
# Script: install_zsh.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Checks current shell, lists available shells,
#              and helps switch to zsh if desired
# ---------------------------------------

# Source the shell utilities
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
UTILS_PATH="${SCRIPT_DIR}/../UTILS/shell_utils.sh"

# Source the utilities file or exit if not found
if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    echo "Error: Could not find shell utilities at $UTILS_PATH"
    echo "Please ensure shell_utils.sh exists in the UTILS directory."
    exit 1
fi

# Function to check if zsh is installed
check_zsh_installed() {
    if command -v zsh &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if Oh-My-ZSH is installed
check_oh_my_zsh_installed() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        return 0
    else
        return 1
    fi
}

# Function to get the current shell
get_current_shell() {
    echo "$SHELL"
}

# Function to list available shells
list_available_shells() {
    if [ -f "/etc/shells" ]; then
        cat /etc/shells
    else
        echo "Could not find /etc/shells file."
    fi
}

# Function to change shell to zsh - using Apple's official approach
change_to_zsh() {
    # First, check if zsh is in /etc/shells (Apple's recommended approach)
    local zsh_path=$(grep -E "\/zsh$" /etc/shells | head -1)
    
    if [ -z "$zsh_path" ]; then
        echo "ZSH is not listed in /etc/shells. This is required by Apple's guidelines."
        echo "Available shells in /etc/shells:"
        cat /etc/shells
        return 1
    fi
    
    echo "Found ZSH at: $zsh_path (from /etc/shells)"
    
    # Use Apple's official method
    echo "Using Apple's official method: chsh -s $zsh_path"
    
    # Store the output of chsh in a variable
    local chsh_output
    chsh_output=$(chsh -s "$zsh_path" 2>&1)
    local chsh_status=$?
    
    # Check for the "no changes made" message in the output
    if [[ "$chsh_output" == *"no changes made"* ]]; then
        echo "Error: $chsh_output"
        echo "Official method failed. Trying alternative approaches..."
    elif [ $chsh_status -eq 0 ]; then
        echo "Shell changed successfully using Apple's official method!"
        return 0
    else
        echo "Error: $chsh_output"
        echo "Official method failed. Trying alternative approaches..."
    fi
    
    # Method 2: Try with sudo (sometimes needed)
    echo "Direct shell change failed. You may need to use sudo."
    echo "Would you like to try changing the shell with sudo? (y/n)"
    read -p "> " try_sudo
    
    if [[ "$try_sudo" =~ ^[Yy]$ ]]; then
        echo "Attempting to change shell using sudo..."
        local user=$(whoami)
        if sudo chsh -s "$zsh_path" "$user"; then
            echo "Shell changed successfully with sudo!"
            return 0
        else
            echo "Sudo method failed as well."
        fi
    fi
    
    # Method 3: Manual update to ~/.bash_profile
    echo "Would you like to try manually adding to ~/.bash_profile? (y/n)"
    echo "This won't change your login shell but will start zsh when you open terminals."
    read -p "> " try_manual
    
    if [[ "$try_manual" =~ ^[Yy]$ ]]; then
        echo "Adding zsh launch to your bash profile..."
        
        # Check if the entry already exists
        if ! grep -q "exec $zsh_path" ~/.bash_profile 2>/dev/null; then
            echo "# Automatically switch to zsh" >> ~/.bash_profile
            echo "[ -f $zsh_path ] && exec $zsh_path" >> ~/.bash_profile
            echo "Added zsh launch command to ~/.bash_profile"
            echo "Next time you open a terminal, it should automatically switch to zsh."
            return 0
        else
            echo "Entry already exists in ~/.bash_profile"
        fi
    fi
    
    return 1
}

# Function to install Oh-My-ZSH
install_oh_my_zsh() {
    echo "Installing Oh-My-ZSH..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    local install_status=$?
    if [ $install_status -eq 0 ]; then
        echo -e "\033[32m----------------------------------"
        echo -e "Oh-My-ZSH installed successfully!"
        echo -e "You can customize it by editing ~/.zshrc"
        echo -e "----------------------------------\033[0m"
        return 0
    else
        echo -e "\033[31m----------------------------------"
        echo -e "Failed to install Oh-My-ZSH."
        echo -e "You can try installing it manually with:"
        echo -e "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
        echo -e "----------------------------------\033[0m"
        return 1
    fi
}

# Display welcome message
echo -e "\033[32m----------------------------------"
echo -e "Welcome to ZSH Installer"
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)"
echo -e "----------------------------------\033[0m"
echo ""

# Get current shell information
current_shell=$(get_current_shell)
mk_log "
Current shell information:
-------------------------
Shell: $current_shell
" "true" "green"

# Display available shells
echo -e "\033[32m----------------------------------"
echo -e "Available shells on this system:"
echo -e "----------------------------------\033[0m"
list_available_shells | while read -r shell; do
    if [ -n "$shell" ] && [ -x "$shell" ]; then
        if [ "$shell" == "$current_shell" ]; then
            echo -e "\033[32m$shell (current)\033[0m"
        else
            echo "$shell"
        fi
    fi
done
echo ""

# Check if zsh is installed
if check_zsh_installed; then
    zsh_path=$(command -v zsh)
    
    # Check if zsh is already the default shell
    if [ "$current_shell" == "$zsh_path" ]; then
        mk_log "
ZSH is already your default shell!

Version information:
$(zsh --version)
" "true" "green"

        # Check if Oh-My-ZSH is installed
        if ! check_oh_my_zsh_installed; then
            # Oh-My-ZSH is not installed, ask if user wants to install it
            read -p "Oh-My-ZSH is not installed. Would you like to install it now? (y/n): " install_omz_choice
            if [[ "$install_omz_choice" =~ ^[Yy]$ ]]; then
                install_oh_my_zsh
            else
                echo -e "\033[31m----------------------------------"
                echo -e "Oh-My-ZSH installation skipped."
                echo -e "You can install it later with:"
                echo -e "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
                echo -e "----------------------------------\033[0m"
            fi
        else
            mk_log "
Oh-My-ZSH is already installed!
You can customize it by editing ~/.zshrc
" "true" "green"
        fi
    else
        # Ask if user wants to change to zsh
        read -p "Do you want to change your default shell to ZSH? (y/n): " change_choice
        if [[ "$change_choice" =~ ^[Yy]$ ]]; then
            # Show current shell in red before changing
            echo -e "\033[31mCurrently using: $current_shell\033[0m"
            
            mk_log "
Note: You will be prompted for your password to change the shell.
There are multiple methods we'll try if the standard approach fails.
" "false" "default"

            if change_to_zsh; then
                # Show new shell in green after successful change
                echo -e "\033[32mSwitching to: $zsh_path\033[0m"
                
                mk_log "
Successfully changed your shell to ZSH!

IMPORTANT: You must log out completely and log back in for
           the changes to take effect. Your current terminal
           sessions will continue using the old shell.

To switch to ZSH immediately in this terminal session, run:
    exec zsh
" "true" "green"

                # Ask if user wants to install Oh-My-ZSH
                read -p "Would you like to install Oh-My-ZSH now? (y/n): " install_omz
                if [[ "$install_omz" =~ ^[Yy]$ ]]; then
                    install_oh_my_zsh
                else
                    echo "You can install Oh-My-ZSH later with:"
                    echo 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
                fi

                # Ask if user wants to switch to zsh immediately
                read -p "Would you like to switch to ZSH in this session now? (y/n): " switch_now
                if [[ "$switch_now" =~ ^[Yy]$ ]]; then
                    echo "Switching to ZSH now..."
                    exec zsh
                fi
            else
                mk_log "
All automated methods to change your shell failed.

You can try these manual approaches:

1. Use sudo directly:
   sudo chsh -s $(command -v zsh) $USER

2. Add this line to your ~/.bash_profile:
   [ -f $(command -v zsh) ] && exec $(command -v zsh)
   
3. Edit /etc/shells to ensure it contains the zsh path:
   $(command -v zsh)
   Then try chsh -s $(command -v zsh) again.

4. On macOS, you can also set the shell in Terminal preferences.
" "true" "red"
            fi
        else
            # Show the current shell in red to highlight what we're keeping
            echo -e "\033[31mKeeping current shell: $current_shell\033[0m"
            
            # More creative rejection message in red
            echo -e "\033[31m----------------------------------"
            echo -e "Shell change aborted! Staying with your trusty old shell."
            echo -e "You're missing out on ZSH's powerful features like:"
            echo -e "- Advanced tab completion"
            echo -e "- Spelling correction"
            echo -e "- Shared command history between sessions"
            echo -e "- Powerful prompt themes with Oh-My-ZSH"
            echo -e ""
            echo -e "Run this script again if you change your mind!"
            echo -e "----------------------------------\033[0m"
            echo ""
        fi
    fi
else
    mk_log "
ZSH is not installed on this system.

You can install it using your package manager:
- macOS: brew install zsh
- Ubuntu/Debian: sudo apt install zsh
- Fedora: sudo dnf install zsh
" "true" "red"
fi