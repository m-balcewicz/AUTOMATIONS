#!/bin/bash
# ---------------------------------------
# Script: install_fonts.sh  
# Author: Martin Balcewicz
# Date: October 2025
# Description: Installs Nerd Fonts for better terminal experience
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

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Install JetBrainsMono Nerd Font on macOS
install_font_macos() {
    local font_dir="$HOME/Library/Fonts"
    
    if [ -f "$font_dir/JetBrainsMonoNLNerdFont-Regular.ttf" ]; then
        mk_log "JetBrainsMono Nerd Font already installed on macOS" "false" "green" 2>/dev/null || echo "✓ JetBrainsMono Nerd Font already installed"
        return 0
    fi
    
    mk_log "Installing JetBrainsMono Nerd Font on macOS..." "false" "blue" 2>/dev/null || echo "Installing JetBrainsMono Nerd Font..."
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download font
    if command -v curl &> /dev/null; then
        curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    elif command -v wget &> /dev/null; then
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    else
        mk_log "Error: Neither curl nor wget available" "false" "red" 2>/dev/null || echo "❌ Error: Neither curl nor wget available"
        return 1
    fi
    
    # Extract and install
    unzip -q JetBrainsMono.zip
    cp *.ttf "$font_dir/"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    mk_log "JetBrainsMono Nerd Font installed successfully on macOS!" "false" "green" 2>/dev/null || echo "✓ Font installed successfully!"
}

# Install JetBrainsMono Nerd Font on Linux
install_font_linux() {
    local font_dir="$HOME/.local/share/fonts"
    
    if [ -f "$font_dir/JetBrainsMonoNLNerdFont-Regular.ttf" ]; then
        mk_log "JetBrainsMono Nerd Font already installed on Linux" "false" "green" 2>/dev/null || echo "✓ JetBrainsMono Nerd Font already installed"
        return 0
    fi
    
    mk_log "Installing JetBrainsMono Nerd Font on Linux..." "false" "blue" 2>/dev/null || echo "Installing JetBrainsMono Nerd Font..."
    
    # Create fonts directory
    mkdir -p "$font_dir"
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download font
    if command -v curl &> /dev/null; then
        curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    elif command -v wget &> /dev/null; then
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    else
        mk_log "Error: Neither curl nor wget available" "false" "red" 2>/dev/null || echo "❌ Error: Neither curl nor wget available"
        return 1
    fi
    
    # Extract and install
    unzip -q JetBrainsMono.zip
    cp *.ttf "$font_dir/"
    
    # Update font cache
    if command -v fc-cache &> /dev/null; then
        fc-cache -fv > /dev/null 2>&1
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    mk_log "JetBrainsMono Nerd Font installed successfully on Linux!" "false" "green" 2>/dev/null || echo "✓ Font installed successfully!"
}

# Main installation function
install_fonts() {
    local os_type=$(detect_os)
    
    case "$os_type" in
        "macos")
            install_font_macos
            ;;
        "linux")
            install_font_linux
            ;;
        *)
            mk_log "Unsupported operating system: $os_type" "false" "red" 2>/dev/null || echo "❌ Unsupported OS: $os_type"
            return 1
            ;;
    esac
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_fonts
fi
