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
source "$SCRIPT_DIR/detect_os.sh"

# Configuration variables
THEME_REPO="https://github.com/romkatv/powerlevel10k.git"
THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Check if oh-my-zsh is installed
check_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        mk_log "Oh-My-Zsh not found! Please install it first using install_oh_my_zsh.sh" "false" "red" 2>/dev/null || echo "❌ Oh-My-Zsh not found!"
        return 1
    fi
    return 0
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    mk_log "Installing Powerlevel10k theme..." "false" "blue" 2>/dev/null || echo "📦 Installing Powerlevel10k..."
    
    # Check if already installed
    if [ -d "$THEME_DIR" ]; then
        mk_log "Powerlevel10k already installed - updating..." "false" "yellow" 2>/dev/null || echo "⚠ Updating Powerlevel10k..."
        cd "$THEME_DIR" && git pull
    else
        # Clone the repository
        git clone --depth=1 "$THEME_REPO" "$THEME_DIR"
    fi
    
    if [ $? -eq 0 ]; then
        mk_log "Powerlevel10k installed successfully!" "false" "green" 2>/dev/null || echo "✓ Powerlevel10k installed!"
    else
        mk_log "Failed to install Powerlevel10k" "false" "red" 2>/dev/null || echo "❌ Powerlevel10k installation failed!"
        return 1
    fi
}

# Configure ZSH to use Powerlevel10k
configure_theme() {
    local zshrc="$HOME/.zshrc"
    
    mk_log "Configuring ZSH to use Powerlevel10k..." "false" "blue" 2>/dev/null || echo "⚙️ Configuring theme..."
    
    # Check if theme is already set
    if grep -q "ZSH_THEME.*powerlevel10k" "$zshrc" 2>/dev/null; then
        mk_log "Powerlevel10k theme already configured" "false" "green" 2>/dev/null || echo "✓ Theme already configured"
    else
        # Backup current .zshrc
        cp "$zshrc" "${zshrc}.backup.$(date +%Y%m%d%H%M%S)" 2>/dev/null
        
        # Update theme in .zshrc
        if [ -f "$zshrc" ]; then
            sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$zshrc"
        else
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$zshrc"
        fi
        
        mk_log "Theme configured successfully!" "false" "green" 2>/dev/null || echo "✓ Theme configured!"
    fi
}

# Main installation function
install_p10k() {
    echo "========================================"
    echo "Powerlevel10k Theme Installation"
    echo "========================================"
    echo ""
    
    # Check prerequisites
    if ! check_oh_my_zsh; then
        return 1
    fi
    
    # Install theme
    install_powerlevel10k
    
    # Configure theme
    configure_theme
    
    mk_log "Powerlevel10k installation complete!" "false" "green" 2>/dev/null || echo "✓ Installation complete!"
    echo ""
    echo "To activate the theme:"
    echo "1. Restart your terminal or run: exec zsh"
    echo "2. Configure the theme: p10k configure"
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_p10k
fi
