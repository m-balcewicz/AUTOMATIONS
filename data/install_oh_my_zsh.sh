#!/bin/bash
# ---------------------------------------
# Script: install_oh_my_zsh.sh
# Author: Martin Balcewicz
# Date: October 2025
# Description: Installs Oh-My-Zsh if not already installed
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

# Check if Oh-My-Zsh is already installed
check_oh_my_zsh_installed() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        return 0  # Already installed
    else
        return 1  # Not installed
    fi
}

# Install Oh-My-Zsh
install_oh_my_zsh() {
    if check_oh_my_zsh_installed; then
        mk_log "Oh-My-Zsh is already installed" "false" "green" 2>/dev/null || echo "✓ Oh-My-Zsh is already installed"
        return 0
    fi
    
    mk_log "Installing Oh-My-Zsh..." "false" "blue" 2>/dev/null || echo "Installing Oh-My-Zsh..."
    
    # Download and install Oh-My-Zsh
    if command -v curl &> /dev/null; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    elif command -v wget &> /dev/null; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        mk_log "Error: Neither curl nor wget is available. Cannot download Oh-My-Zsh installer." "false" "red" 2>/dev/null || echo "❌ Error: Neither curl nor wget is available"
        return 1
    fi
    
    # Verify installation
    if check_oh_my_zsh_installed; then
        mk_log "Oh-My-Zsh installed successfully!" "false" "green" 2>/dev/null || echo "✓ Oh-My-Zsh installed successfully!"
        return 0
    else
        mk_log "Oh-My-Zsh installation failed!" "false" "red" 2>/dev/null || echo "❌ Oh-My-Zsh installation failed!"
        return 1
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_oh_my_zsh
fi
