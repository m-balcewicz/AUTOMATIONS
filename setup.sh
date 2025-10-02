#!/bin/bash
# ===============================================
# Master Setup Script
# Author: Martin Balcewicz
# Date: October 2025
# Description: Orchestrates complete development environment setup
# ===============================================

# Get script directory and source utilities
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
UTILS_PATH="${SCRIPT_DIR}/utils/shell_utils.sh"

# Source utilities if available
if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    # Simple fallback logging functions
    mk_log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"; }
    red() { echo -e "\033[31m$1\033[0m"; }
    green() { echo -e "\033[32m$1\033[0m"; }
    yellow() { echo -e "\033[33m$1\033[0m"; }
    blue() { echo -e "\033[34m$1\033[0m"; }
    purple() { echo -e "\033[35m$1\033[0m"; }
fi

# Source OS detection
source "$SCRIPT_DIR/data/detect_os.sh"

# Configuration
DATA_DIR="$SCRIPT_DIR/data"
PERSONAL_DIR="$SCRIPT_DIR/personal"

# Display banner
show_banner() {
    echo ""
    blue "=================================================="
    purple "     🚀 Development Environment Setup"
    purple "        Complete ZSH & Terminal Configuration"
    blue "=================================================="
    echo ""
    echo "OS Detected: $(get_os_type)"
    echo "Script Location: $SCRIPT_DIR"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    mk_log "Checking prerequisites..." "false" "blue" 2>/dev/null || echo "🔍 Checking prerequisites..."
    
    # Check for git
    if ! command -v git &> /dev/null; then
        mk_log "Git is required but not installed. Please install git first." "false" "red" 2>/dev/null || echo "❌ Git is required!"
        return 1
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        mk_log "Curl is required but not installed. Please install curl first." "false" "red" 2>/dev/null || echo "❌ Curl is required!"
        return 1
    fi
    
    mk_log "Prerequisites check passed!" "false" "green" 2>/dev/null || echo "✓ Prerequisites OK!"
    return 0
}

# Menu system
show_menu() {
    echo ""
    yellow "What would you like to install?"
    echo ""
    echo "1) Complete Setup (Recommended)"
    echo "2) ZSH & Oh-My-Zsh Only"
    echo "3) Personal Configuration Only"
    echo "4) Individual Components"
    echo "5) Exit"
    echo ""
    echo -n "Enter your choice [1-5]: "
}

# Complete setup function
complete_setup() {
    echo ""
    blue "========================================="
    blue "Starting Complete Setup"
    blue "========================================="
    
    # Step 1: Install Oh-My-Zsh
    mk_log "Step 1: Installing Oh-My-Zsh..." "false" "purple" 2>/dev/null || echo "🔧 Installing Oh-My-Zsh..."
    if [ -x "$DATA_DIR/install_oh_my_zsh.sh" ]; then
        "$DATA_DIR/install_oh_my_zsh.sh"
    else
        echo "⚠ Warning: install_oh_my_zsh.sh not found or not executable"
    fi
    
    # Step 2: Install Fonts
    mk_log "Step 2: Installing Nerd Fonts..." "false" "purple" 2>/dev/null || echo "🔧 Installing Fonts..."
    if [ -x "$DATA_DIR/install_fonts.sh" ]; then
        "$DATA_DIR/install_fonts.sh"
    else
        echo "⚠ Warning: install_fonts.sh not found or not executable"
    fi
    
    # Step 3: Install Powerlevel10k
    mk_log "Step 3: Installing Powerlevel10k theme..." "false" "purple" 2>/dev/null || echo "🔧 Installing Powerlevel10k..."
    if [ -x "$DATA_DIR/install_powerlevel10k.sh" ]; then
        "$DATA_DIR/install_powerlevel10k.sh"
    else
        echo "⚠ Warning: install_powerlevel10k.sh not found or not executable"
    fi
    
    # Step 4: Install ZSH Plugins
    mk_log "Step 4: Installing ZSH plugins..." "false" "purple" 2>/dev/null || echo "🔧 Installing ZSH Plugins..."
    if [ -x "$DATA_DIR/install_zsh_plugins.sh" ]; then
        "$DATA_DIR/install_zsh_plugins.sh"
    else
        echo "⚠ Warning: install_zsh_plugins.sh not found or not executable"
    fi
    
    # Step 5: Setup Personal Environment
    mk_log "Step 5: Setting up personal configuration..." "false" "purple" 2>/dev/null || echo "🔧 Personal Configuration..."
    if [ -x "$PERSONAL_DIR/setup_personal_env.sh" ]; then
        "$PERSONAL_DIR/setup_personal_env.sh"
    else
        echo "⚠ Warning: setup_personal_env.sh not found or not executable"
    fi
    
    # Optional: Install additional tools
    echo ""
    echo "Optional: Install additional development tools?"
    echo "1) Install Neovim"
    echo "2) Skip additional tools"
    echo -n "Enter choice [1-2]: "
    read -r choice
    
    if [ "$choice" = "1" ]; then
        mk_log "Installing Neovim..." "false" "purple" 2>/dev/null || echo "🔧 Installing Neovim..."
        if [ -x "$DATA_DIR/install_neovim.sh" ]; then
            "$DATA_DIR/install_neovim.sh"
        else
            echo "⚠ Warning: install_neovim.sh not found or not executable"
        fi
    fi
    
    # Setup complete
    echo ""
    green "========================================="
    green "🎉 Complete Setup Finished!"
    green "========================================="
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: exec zsh"
    echo "2. Configure Powerlevel10k if prompted: p10k configure"
    echo "3. Enjoy your new development environment!"
    echo ""
}

# Individual components menu
individual_components() {
    echo ""
    yellow "Select individual components to install:"
    echo ""
    echo "1) Oh-My-Zsh"
    echo "2) Nerd Fonts"
    echo "3) Powerlevel10k Theme"
    echo "4) ZSH Plugins"
    echo "5) Personal Configuration"
    echo "6) Neovim"
    echo "7) Back to main menu"
    echo ""
    echo -n "Enter your choice [1-7]: "
    
    read -r choice
    case $choice in
        1) [ -x "$DATA_DIR/install_oh_my_zsh.sh" ] && "$DATA_DIR/install_oh_my_zsh.sh" ;;
        2) [ -x "$DATA_DIR/install_fonts.sh" ] && "$DATA_DIR/install_fonts.sh" ;;
        3) [ -x "$DATA_DIR/install_powerlevel10k.sh" ] && "$DATA_DIR/install_powerlevel10k.sh" ;;
        4) [ -x "$DATA_DIR/install_zsh_plugins.sh" ] && "$DATA_DIR/install_zsh_plugins.sh" ;;
        5) [ -x "$PERSONAL_DIR/setup_personal_env.sh" ] && "$PERSONAL_DIR/setup_personal_env.sh" ;;
        6) [ -x "$DATA_DIR/install_neovim.sh" ] && "$DATA_DIR/install_neovim.sh" ;;
        7) return ;;
        *) echo "Invalid choice" ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read -r
}

# Main execution loop
main() {
    show_banner
    
    # Check prerequisites
    if ! check_prerequisites; then
        exit 1
    fi
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                complete_setup
                break
                ;;
            2)
                echo "Installing ZSH & Oh-My-Zsh..."
                [ -x "$DATA_DIR/install_oh_my_zsh.sh" ] && "$DATA_DIR/install_oh_my_zsh.sh"
                [ -x "$DATA_DIR/install_zsh_plugins.sh" ] && "$DATA_DIR/install_zsh_plugins.sh"
                break
                ;;
            3)
                echo "Setting up personal configuration..."
                [ -x "$PERSONAL_DIR/setup_personal_env.sh" ] && "$PERSONAL_DIR/setup_personal_env.sh"
                break
                ;;
            4)
                individual_components
                ;;
            5)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter 1-5."
                ;;
        esac
    done
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
