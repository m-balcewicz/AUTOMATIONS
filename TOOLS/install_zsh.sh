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

# Get current OS
CURRENT_OS=$(detect_os)

# Function to check if zsh is installed
check_zsh_installed() {
    if command -v zsh &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install ZSH based on the OS
install_zsh() {
    case "$CURRENT_OS" in
        "macos")
            # For macOS, we prefer using Homebrew if available
            if command -v brew &>/dev/null; then
                mk_log "Installing ZSH via Homebrew..." "false" "green"
                brew install zsh
            else
                mk_log "
Homebrew is not installed. To install ZSH on macOS:
1. Install Homebrew first: ./install_brew.sh
2. Then run this script again
" "true" "red"
                exit 1
            fi
            ;;
            
        "linux")
            # Detect Linux distribution and use appropriate package manager
            local distro=$(get_linux_distro)
            
            case "$distro" in
                "ubuntu"|"debian"|"pop"|"elementary"|"linuxmint")
                    mk_log "Installing ZSH via apt..." "false" "green"
                    sudo apt update
                    sudo apt install -y zsh
                    ;;
                    
                "fedora")
                    mk_log "Installing ZSH via dnf..." "false" "green"
                    sudo dnf install -y zsh
                    ;;
                    
                "centos"|"rhel")
                    mk_log "Installing ZSH via yum..." "false" "green"
                    sudo yum install -y zsh
                    ;;
                    
                "arch"|"manjaro")
                    mk_log "Installing ZSH via pacman..." "false" "green"
                    sudo pacman -Sy zsh
                    ;;
                    
                "opensuse"|"suse")
                    mk_log "Installing ZSH via zypper..." "false" "green"
                    sudo zypper install -y zsh
                    ;;
                    
                *)
                    mk_log "
Could not determine your Linux distribution.
Please install ZSH manually using your package manager.
For example:
- Ubuntu/Debian: sudo apt install zsh
- Fedora: sudo dnf install zsh
- CentOS/RHEL: sudo yum install zsh
- Arch: sudo pacman -S zsh
" "true" "red"
                    exit 1
                    ;;
            esac
            ;;
            
        *)
            mk_log "Unsupported operating system: $CURRENT_OS" "false" "red"
            exit 1
            ;;
    esac
    
    # Check if installation was successful
    if check_zsh_installed; then
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
        echo "Available shells (from command):"
        compgen -c | grep 'sh$' | sort -u
    fi
}

# Function to change shell to zsh
change_to_zsh() {
    # First, check if zsh is in /etc/shells 
    local zsh_path=$(grep -E "\/zsh$" /etc/shells 2>/dev/null | head -1)
    
    if [ -z "$zsh_path" ]; then
        # If not in /etc/shells, get it from command
        zsh_path=$(command -v zsh)
        
        if [ -z "$zsh_path" ]; then
            echo "Cannot find ZSH path. Is it installed?"
            return 1
        fi
        
        echo "ZSH is not listed in /etc/shells. Found at: $zsh_path"
        
        # On Linux, we need to add it to /etc/shells first
        if [[ "$CURRENT_OS" == "linux" ]]; then
            echo "Adding ZSH to /etc/shells (requires sudo)..."
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
    fi
    
    echo "Found ZSH at: $zsh_path"
    
    # Use standard method 
    echo "Changing shell using chsh -s $zsh_path"
    
    # Store the output of chsh in a variable
    local chsh_output
    chsh_output=$(chsh -s "$zsh_path" 2>&1)
    local chsh_status=$?
    
    # Check for the "no changes made" message in the output
    if [[ "$chsh_output" == *"no changes made"* ]]; then
        echo "Error: $chsh_output"
        echo "Standard method failed. Trying alternative approaches..."
    elif [ $chsh_status -eq 0 ]; then
        echo "Shell changed successfully using standard method!"
        return 0
    else
        echo "Error: $chsh_output"
        echo "Standard method failed. Trying alternative approaches..."
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
    
    # Method 3: Manual update to profile file
    local profile_file
    if [[ "$CURRENT_OS" == "macos" ]]; then
        profile_file="$HOME/.bash_profile"
    else
        profile_file="$HOME/.bashrc"
    fi
    
    echo "Would you like to try manually adding to $profile_file? (y/n)"
    echo "This won't change your login shell but will start zsh when you open terminals."
    read -p "> " try_manual
    
    if [[ "$try_manual" =~ ^[Yy]$ ]]; then
        echo "Adding zsh launch to your profile..."
        
        # Check if the entry already exists
        if ! grep -q "exec $zsh_path" "$profile_file" 2>/dev/null; then
            echo "# Automatically switch to zsh" >> "$profile_file"
            echo "[ -f $zsh_path ] && exec $zsh_path" >> "$profile_file"
            echo "Added zsh launch command to $profile_file"
            echo "Next time you open a terminal, it should automatically switch to zsh."
            return 0
        else
            echo "Entry already exists in $profile_file"
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
        mk_log "
Oh-My-ZSH installed successfully!
You can customize it by editing ~/.zshrc
" "true" "green"
        return 0
    else
        mk_log "
Failed to install Oh-My-ZSH.
You can try installing it manually with:
sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"
" "true" "red"
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

# Show detected operating system
mk_log "Detected operating system: $CURRENT_OS" "false" "green"
if [[ "$CURRENT_OS" == "linux" ]]; then
    LINUX_DISTRO=$(get_linux_distro)
    mk_log "Linux distribution: $LINUX_DISTRO" "false" "green"
fi
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
                mk_log "
Oh-My-ZSH installation skipped.
You can install it later with:
sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"
" "true" "red"
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

2. Add this line to your profile file:
   [ -f $(command -v zsh) ] && exec $(command -v zsh)
   
3. Edit /etc/shells to ensure it contains the zsh path:
   $(command -v zsh)
   Then try chsh -s $(command -v zsh) again.
" "true" "red"
            fi
        else
            # Show the current shell in red to highlight what we're keeping
            echo -e "\033[31mKeeping current shell: $current_shell\033[0m"
            
            # More creative rejection message in red
            mk_log "
Shell change aborted! Staying with your trusty old shell.
You're missing out on ZSH's powerful features like:
- Advanced tab completion
- Spelling correction
- Shared command history between sessions
- Powerful prompt themes with Oh-My-ZSH

Run this script again if you change your mind!
" "true" "red"
        fi
    fi
else
    mk_log "
ZSH is not installed on this system.
" "true" "red"
    
    # Ask if user wants to install ZSH
    read -p "Would you like to install ZSH now? (y/n): " install_zsh_choice
    if [[ "$install_zsh_choice" =~ ^[Yy]$ ]]; then
        if install_zsh; then
            mk_log "
ZSH has been successfully installed!

Version information:
$(zsh --version)
" "true" "green"
            
            # Now ask if they want to change their shell to ZSH
            read -p "Do you want to change your default shell to ZSH? (y/n): " change_choice
            if [[ "$change_choice" =~ ^[Yy]$ ]]; then
                if change_to_zsh; then
                    mk_log "
Successfully changed your shell to ZSH!
You must log out and log back in for the changes to take full effect.
" "true" "green"
                    
                    # Ask if user wants to install Oh-My-ZSH
                    read -p "Would you like to install Oh-My-ZSH now? (y/n): " install_omz
                    if [[ "$install_omz" =~ ^[Yy]$ ]]; then
                        install_oh_my_zsh
                    fi
                    
                    # Ask if user wants to switch to zsh immediately
                    read -p "Would you like to switch to ZSH in this session now? (y/n): " switch_now
                    if [[ "$switch_now" =~ ^[Yy]$ ]]; then
                        echo "Switching to ZSH now..."
                        exec zsh
                    fi
                fi
            fi
        else
            mk_log "
Failed to install ZSH. Please try to install it manually using your package manager:
- macOS: brew install zsh
- Ubuntu/Debian: sudo apt install zsh
- Fedora: sudo dnf install zsh
- CentOS/RHEL: sudo yum install zsh
- Arch: sudo pacman -S zsh
" "true" "red"
        fi
    else
        mk_log "Installation cancelled by user." "false" "red"
    fi
fi