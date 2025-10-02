#!/bin/bash
# ---------------------------------------
# Script: setup_personal_env.sh
# Author: Martin Balcewicz
# Date: October 2025
# Description: Sets up personal ZSH environment with configurations and aliases
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

# Backup existing configuration
backup_zsh_config() {
    local backup_dir="$HOME/.zsh_backup_$(date +%Y%m%d_%H%M%S)"
    
    mk_log "Creating backup of your ZSH configuration at $backup_dir..." "false" "blue" 2>/dev/null || echo "Creating backup..."
    mkdir -p "$backup_dir"
    
    # Backup main config files
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$backup_dir/"
    [ -f "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$backup_dir/"
    
    # Backup custom ZSH files
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ -d "$custom_dir" ]; then
        mkdir -p "$backup_dir/custom"
        cp -r "$custom_dir"/* "$backup_dir/custom/" 2>/dev/null || true
    fi
    
    mk_log "Backup created successfully!" "false" "green" 2>/dev/null || echo "✓ Backup created!"
}

# Copy configuration files
copy_config_files() {
    local configs_dir="$SCRIPT_DIR/configs"
    
    mk_log "Copying ZSH configuration files..." "false" "blue" 2>/dev/null || echo "Copying configuration files..."
    
    # Copy main config files
    if [ -f "$configs_dir/zshrc" ]; then
        cp "$configs_dir/zshrc" "$HOME/.zshrc"
        echo "✓ Copied zshrc to $HOME/.zshrc"
    else
        echo "⚠ Warning: zshrc not found in $configs_dir"
    fi
    
    if [ -f "$configs_dir/p10k.zsh" ]; then
        cp "$configs_dir/p10k.zsh" "$HOME/.p10k.zsh"
        echo "✓ Copied p10k.zsh to $HOME/.p10k.zsh"
    else
        echo "⚠ Warning: p10k.zsh not found in $configs_dir"
    fi
}

# Copy alias files
copy_alias_files() {
    local aliases_dir="$SCRIPT_DIR/aliases"
    local dest_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local os_type=$(detect_os)
    
    # Create destination directory
    mkdir -p "$dest_dir"
    
    mk_log "Copying ZSH alias files..." "false" "blue" 2>/dev/null || echo "Copying alias files..."
    
    # Common alias files
    local common_files=("system.zsh" "dev.zsh" "navigation.zsh" "remote.zsh" "python.zsh")
    
    for file in "${common_files[@]}"; do
        if [ -f "$aliases_dir/$file" ]; then
            cp "$aliases_dir/$file" "$dest_dir/"
            echo "✓ Copied $file to $dest_dir/"
        else
            echo "⚠ Warning: $file not found in $aliases_dir"
        fi
    done
    
    # OS-specific files
    if [ "$os_type" = "macos" ]; then
        if [ -f "$aliases_dir/macos.zsh" ]; then
            cp "$aliases_dir/macos.zsh" "$dest_dir/"
            echo "✓ Copied macos.zsh to $dest_dir/"
        fi
    elif [ "$os_type" = "linux" ]; then
        if [ -f "$aliases_dir/linux.zsh" ]; then
            cp "$aliases_dir/linux.zsh" "$dest_dir/"
            echo "✓ Copied linux.zsh to $dest_dir/"
        fi
        # Create placeholder for macOS to avoid errors
        if [ ! -f "$dest_dir/macos.zsh" ]; then
            echo "# macOS aliases skipped on Linux" > "$dest_dir/macos.zsh"
            echo "✓ Created placeholder macos.zsh"
        fi
    fi
}

# Copy SSH configuration
copy_ssh_config() {
    local ssh_source="$SCRIPT_DIR/configs/.ssh"
    local ssh_dest="$HOME/.ssh"
    local config_file="config"
    
    # Only proceed if source exists
    if [ ! -f "$ssh_source/$config_file" ]; then
        mk_log "No SSH config found - skipping SSH configuration" "false" "yellow" 2>/dev/null || echo "ℹ No SSH config found"
        return 0
    fi
    
    # Create destination directory
    mkdir -p "$ssh_dest"
    chmod 700 "$ssh_dest"
    
    # Check if destination exists
    if [ -f "$ssh_dest/$config_file" ]; then
        mk_log "SSH config already exists - creating backup" "false" "yellow" 2>/dev/null || echo "⚠ SSH config exists, backing up..."
        cp "$ssh_dest/$config_file" "$ssh_dest/${config_file}.bak.$(date +%Y%m%d%H%M%S)"
        
        echo "Would you like to merge (m) or replace (r) your existing SSH config? [m/r]:"
        read -r ssh_choice
        
        case "$ssh_choice" in
            [Rr]*)
                cp "$ssh_source/$config_file" "$ssh_dest/"
                echo "✓ Replaced SSH config"
                ;;
            *)
                echo "ℹ Keeping existing SSH config"
                ;;
        esac
    else
        cp "$ssh_source/$config_file" "$ssh_dest/"
        echo "✓ Copied SSH config"
    fi
    
    # Set proper permissions
    chmod 600 "$ssh_dest/$config_file"
}

# Main setup function
setup_personal_env() {
    echo "========================================"
    echo "Personal ZSH Environment Setup"
    echo "========================================"
    echo ""
    
    # Backup existing config
    backup_zsh_config
    
    # Copy files
    copy_config_files
    copy_alias_files
    copy_ssh_config
    
    mk_log "Personal environment setup complete!" "false" "green" 2>/dev/null || echo "✓ Setup complete!"
    echo ""
    echo "To apply changes, run: exec zsh"
    echo "Or restart your terminal"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_personal_env
fi
