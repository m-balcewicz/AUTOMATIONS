#!/bin/bash
# ---------------------------------------
# Script: install_neovim.sh
# Author: Martin Balcewicz
# Date: October 2025
# Description: Installs Neovim editor on macOS and Linux systems
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
NVIM_VERSION="v0.9.5"  # Latest stable version

# Check if OS is supported
check_os_support() {
    local current_os=$(get_os_type)
    if [[ "$current_os" != "macos" && "$current_os" != "linux" ]]; then
        mk_log "This script only supports macOS and Linux. Detected OS: $current_os" "false" "red" 2>/dev/null || echo "❌ Unsupported OS: $current_os"
        exit 1
    fi
}

# Install Neovim on macOS
install_neovim_macos() {
    mk_log "Installing Neovim on macOS..." "false" "blue" 2>/dev/null || echo "📦 Installing Neovim on macOS..."
    
    # Check if Homebrew is available
    if ! command -v brew &> /dev/null; then
        mk_log "Homebrew not found. Installing Homebrew first..." "false" "yellow" 2>/dev/null || echo "⚠ Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install or upgrade Neovim
    if brew list neovim &> /dev/null; then
        mk_log "Neovim already installed - upgrading..." "false" "yellow" 2>/dev/null || echo "⚠ Upgrading Neovim..."
        brew upgrade neovim
    else
        brew install neovim
    fi
    
    if [ $? -eq 0 ]; then
        mk_log "Neovim installed successfully on macOS!" "false" "green" 2>/dev/null || echo "✓ Neovim installed!"
    else
        mk_log "Failed to install Neovim on macOS" "false" "red" 2>/dev/null || echo "❌ Neovim installation failed!"
        return 1
    fi
}

# Install Neovim on Linux
install_neovim_linux() {
    mk_log "Installing Neovim on Linux..." "false" "blue" 2>/dev/null || echo "📦 Installing Neovim on Linux..."
    
    # Detect package manager and install
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y neovim
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum install -y neovim
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y neovim
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        sudo pacman -S --noconfirm neovim
    else
        # Fallback: try to install from GitHub releases
        mk_log "No package manager found. Installing from GitHub releases..." "false" "yellow" 2>/dev/null || echo "⚠ Installing from GitHub..."
        install_neovim_from_github
        return $?
    fi
    
    if [ $? -eq 0 ]; then
        mk_log "Neovim installed successfully on Linux!" "false" "green" 2>/dev/null || echo "✓ Neovim installed!"
    else
        mk_log "Failed to install Neovim on Linux" "false" "red" 2>/dev/null || echo "❌ Neovim installation failed!"
        return 1
    fi
}

# Install Neovim from GitHub releases (fallback)
install_neovim_from_github() {
    local install_dir="$HOME/.local/bin"
    local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
    
    mk_log "Installing Neovim AppImage from GitHub..." "false" "blue" 2>/dev/null || echo "📦 Installing Neovim AppImage..."
    
    # Create directory
    mkdir -p "$install_dir"
    
    # Download and install
    curl -L "$nvim_url" -o "$install_dir/nvim"
    chmod +x "$install_dir/nvim"
    
    # Create symlink for convenience
    if [ ! -f "$install_dir/neovim" ]; then
        ln -s "$install_dir/nvim" "$install_dir/neovim"
    fi
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        mk_log "Added $install_dir to PATH in shell configs" "false" "green" 2>/dev/null || echo "✓ Added to PATH"
    fi
    
    if [ -f "$install_dir/nvim" ]; then
        mk_log "Neovim AppImage installed successfully!" "false" "green" 2>/dev/null || echo "✓ Neovim AppImage installed!"
    else
        mk_log "Failed to install Neovim AppImage" "false" "red" 2>/dev/null || echo "❌ AppImage installation failed!"
        return 1
    fi
}

# Setup basic Neovim configuration
setup_neovim_config() {
    local config_dir="$HOME/.config/nvim"
    
    mk_log "Setting up basic Neovim configuration..." "false" "blue" 2>/dev/null || echo "⚙️ Setting up config..."
    
    # Create config directory
    mkdir -p "$config_dir"
    
    # Create basic init.vim if it doesn't exist
    if [ ! -f "$config_dir/init.vim" ]; then
        cat > "$config_dir/init.vim" << 'EOF'
" Basic Neovim configuration
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set expandtab           " Use spaces instead of tabs
set tabstop=4           " Tab width
set shiftwidth=4        " Indent width
set autoindent          " Auto indent
set smartindent         " Smart indent
set wrap                " Wrap lines
set ignorecase          " Ignore case in search
set smartcase           " Smart case in search
set hlsearch            " Highlight search results
set incsearch           " Incremental search
set mouse=a             " Enable mouse support
syntax enable           " Enable syntax highlighting
colorscheme default     " Use default colorscheme
EOF
        mk_log "Created basic init.vim configuration" "false" "green" 2>/dev/null || echo "✓ Basic config created"
    else
        mk_log "Neovim configuration already exists" "false" "yellow" 2>/dev/null || echo "⚠ Config already exists"
    fi
}

# Main installation function
install_neovim() {
    echo "========================================"
    echo "Neovim Installation"
    echo "========================================"
    echo ""
    
    # Check OS support
    check_os_support
    
    local current_os=$(get_os_type)
    
    # Install based on OS
    case "$current_os" in
        "macos")
            install_neovim_macos
            ;;
        "linux")
            install_neovim_linux
            ;;
        *)
            mk_log "Unsupported operating system: $current_os" "false" "red" 2>/dev/null || echo "❌ Unsupported OS"
            return 1
            ;;
    esac
    
    # Setup basic configuration
    setup_neovim_config
    
    # Verify installation
    if command -v nvim &> /dev/null; then
        local nvim_version=$(nvim --version | head -n1)
        mk_log "Neovim installation complete! Version: $nvim_version" "false" "green" 2>/dev/null || echo "✓ Installation complete!"
        echo ""
        echo "To start using Neovim:"
        echo "1. Run: nvim"
        echo "2. For help: :help"
        echo "3. To exit: :q"
        echo ""
    else
        mk_log "Neovim installation verification failed" "false" "red" 2>/dev/null || echo "❌ Installation verification failed!"
        return 1
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_neovim
fi
