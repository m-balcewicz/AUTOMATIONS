#!/bin/bash
# ---------------------------------------
# Script: install_zsh_plugins.sh
# Author: Martin Balcewicz
# Date: October 2025
# Description: Installs ZSH plugins for enhanced shell experience
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
source "$SCRIPT_DIR/detect_os.sh"

# Check if oh-my-zsh is installed
check_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        mk_log "Oh-My-Zsh not found! Please install it first using install_oh_my_zsh.sh" "false" "red" 2>/dev/null || echo "❌ Oh-My-Zsh not found!"
        return 1
    fi
    return 0
}

# Install zsh-autosuggestions plugin
install_autosuggestions() {
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    
    if [ -d "$plugin_dir" ]; then
        mk_log "zsh-autosuggestions already installed - updating..." "false" "yellow" 2>/dev/null || echo "⚠ Updating zsh-autosuggestions..."
        cd "$plugin_dir" && git pull
    else
        mk_log "Installing zsh-autosuggestions..." "false" "blue" 2>/dev/null || echo "📦 Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
    fi
    
    if [ $? -eq 0 ]; then
        mk_log "zsh-autosuggestions installed successfully!" "false" "green" 2>/dev/null || echo "✓ zsh-autosuggestions installed!"
    else
        mk_log "Failed to install zsh-autosuggestions" "false" "red" 2>/dev/null || echo "❌ zsh-autosuggestions installation failed!"
        return 1
    fi
}

# Install zsh-syntax-highlighting plugin
install_syntax_highlighting() {
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    
    if [ -d "$plugin_dir" ]; then
        mk_log "zsh-syntax-highlighting already installed - updating..." "false" "yellow" 2>/dev/null || echo "⚠ Updating zsh-syntax-highlighting..."
        cd "$plugin_dir" && git pull
    else
        mk_log "Installing zsh-syntax-highlighting..." "false" "blue" 2>/dev/null || echo "📦 Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir"
    fi
    
    if [ $? -eq 0 ]; then
        mk_log "zsh-syntax-highlighting installed successfully!" "false" "green" 2>/dev/null || echo "✓ zsh-syntax-highlighting installed!"
    else
        mk_log "Failed to install zsh-syntax-highlighting" "false" "red" 2>/dev/null || echo "❌ zsh-syntax-highlighting installation failed!"
        return 1
    fi
}

# Install additional useful plugins
install_additional_plugins() {
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # Install you-should-use plugin
    local ysu_dir="$plugins_dir/you-should-use"
    if [ ! -d "$ysu_dir" ]; then
        mk_log "Installing you-should-use plugin..." "false" "blue" 2>/dev/null || echo "📦 Installing you-should-use..."
        git clone https://github.com/MichaelAquilina/zsh-you-should-use "$ysu_dir"
    fi
    
    # Install zsh-completions
    local comp_dir="$plugins_dir/zsh-completions"
    if [ ! -d "$comp_dir" ]; then
        mk_log "Installing zsh-completions..." "false" "blue" 2>/dev/null || echo "📦 Installing zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$comp_dir"
    fi
}

# Main installation function
install_zsh_plugins() {
    echo "========================================"
    echo "ZSH Plugins Installation"
    echo "========================================"
    echo ""
    
    # Check prerequisites
    if ! check_oh_my_zsh; then
        return 1
    fi
    
    # Install core plugins
    install_autosuggestions
    install_syntax_highlighting
    
    # Install additional plugins
    install_additional_plugins
    
    mk_log "ZSH plugins installation complete!" "false" "green" 2>/dev/null || echo "✓ All plugins installed!"
    echo ""
    echo "Note: Add these plugins to your .zshrc plugins list:"
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-completions)"
    echo ""
    echo "Restart your terminal or run 'exec zsh' to activate."
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_zsh_plugins
fi
