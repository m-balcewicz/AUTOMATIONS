#!/bin/bash
# ---------------------------------------
# Script: set_myzsh.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Sets up personal ZSH environment with modular alias files
# ---------------------------------------

# Source the shell utilities
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
UTILS_PATH="${SCRIPT_DIR}/../utils/shell_utils.sh"

# Source the utilities file or use local fallback implementations
if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    echo "Warning: Could not find shell utilities at $UTILS_PATH"
    echo "Using local function implementations instead."
    
    # Define color constants to match p10k theme
    # These hex colors are translated to 256-color ANSI codes for terminal use
    CUSTOM_GREEN="\033[38;5;107m"    # ~#74975A
    CUSTOM_RED="\033[38;5;180m"      # ~#C7947B
    CUSTOM_YELLOW="\033[38;5;187m"   # ~#DDDBAE
    CUSTOM_PURPLE="\033[38;5;140m"   # ~#BD8BBE
    CUSTOM_BLUE="\033[38;5;75m"      # ~#649CD3
    CUSTOM_LIGHT_BLUE="\033[38;5;153m" # ~#A7DBFC
    DEFAULT="\033[0m"
    
    # Local fallback implementations of utility functions
    print_style() {
        local message="$1"
        local style="${2:-indented_separator}"
        
        # Determine the style character
        local style_chars="-"
        if [ "$style" == "box" ]; then
            style_chars="#"
        elif [ "$style" == "section" ]; then
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
        
        # Set the color based on the parameter
        local selected_color="$DEFAULT"
        if [ "$color" == "green" ]; then
            selected_color="$CUSTOM_GREEN"
        elif [ "$color" == "red" ]; then
            selected_color="$CUSTOM_RED"
        elif [ "$color" == "yellow" ]; then
            selected_color="$CUSTOM_YELLOW"
        elif [ "$color" == "blue" ]; then
            selected_color="$CUSTOM_BLUE"
        elif [ "$color" == "purple" ]; then
            selected_color="$CUSTOM_PURPLE"
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
We recommend installing it for best experience.
" "true" "yellow"
        
        read -p "Do you want to continue anyway? (y/n): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    return 0
}

# Function to backup existing ZSH configuration
backup_zsh_config() {
    local backup_dir="$HOME/.zsh_backup_$(date +%Y%m%d_%H%M%S)"
    
    mk_log "Creating backup of your ZSH configuration at $backup_dir..." "false" "blue"
    mkdir -p "$backup_dir"
    
    # Backup main config files
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$backup_dir/"
    [ -f "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$backup_dir/"
    
    # Backup all custom ZSH files
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ -d "$custom_dir" ]; then
        mkdir -p "$backup_dir/custom"
        # Copy only the files that are actually being used
        for file in system.zsh dev.zsh macos.zsh navigation.zsh remote.zsh python.zsh; do
            [ -f "$custom_dir/$file" ] && cp "$custom_dir/$file" "$backup_dir/custom/"
        done
    fi
    
    mk_log "Backup created successfully!" "false" "green"
    return 0
}

# Function to copy all zsh files to their destinations
copy_zsh_files() {
    # Define source and destination directories
    local source_dir
    source_dir="$(cd "$(dirname "$0")" && pwd)"
    local dest_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    mk_log "Copying ZSH configuration files..." "false" "blue"
    
    # Copy main config files
    cp "$source_dir/zshrc" "$HOME/.zshrc"
    echo "✓ Copied zshrc to $HOME/.zshrc"
    cp "$source_dir/p10k.zsh" "$HOME/.p10k.zsh"
    echo "✓ Copied p10k.zsh to $HOME/.p10k.zsh"

    # List of modular files to copy (common to all systems)
    local common_files=("system.zsh" "dev.zsh" "navigation.zsh" "remote.zsh" "python.zsh")
    
    # Copy each common modular file
    for file in "${common_files[@]}"; do
        if [ -f "$source_dir/$file" ]; then
            cp "$source_dir/$file" "$dest_dir/"
            echo "✓ Copied $file to $dest_dir/"
        else
            echo "✗ Warning: $file not found in $source_dir"
        fi
    done
    
    # Copy OS-specific files
    if [ "$OS_TYPE" = "macos" ]; then
        if [ -f "$source_dir/macos.zsh" ]; then
            cp "$source_dir/macos.zsh" "$dest_dir/"
            echo "✓ Copied macos.zsh to $dest_dir/"
        fi
    elif [ "$OS_TYPE" = "linux" ]; then
        if [ -f "$source_dir/linux.zsh" ]; then
            cp "$source_dir/linux.zsh" "$dest_dir/"
            echo "✓ Copied linux.zsh to $dest_dir/"
        fi
        # Skip macOS file or create a dummy one to avoid errors
        if [ ! -f "$dest_dir/macos.zsh" ]; then
            echo "# macOS aliases skipped on Linux" > "$dest_dir/macos.zsh"
            echo "✓ Created placeholder macos.zsh"
        fi
    fi
    
    mk_log "All ZSH files have been copied." "false" "green"
    return 0
}

# Function to securely copy SSH config
copy_ssh_config() {
    local source_dir="$(cd "$(dirname "$0")" && pwd)/.ssh"
    local dest_dir="$HOME/.ssh"
    local config_file="config"
    
    # Only proceed if there's a source SSH config
    if [ ! -f "$source_dir/$config_file" ]; then
        mk_log "No SSH config found at $source_dir/$config_file - skipping SSH configuration" "false" "yellow"
        return 0
    fi
    
    # Create destination dir if it doesn't exist
    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir"
        chmod 700 "$dest_dir"
    fi
    
    # Check if destination config already exists
    if [ -f "$dest_dir/$config_file" ]; then
        mk_log "SSH config already exists at $dest_dir/$config_file" "false" "yellow"
        
        # Create backup of existing config
        cp "$dest_dir/$config_file" "$dest_dir/${config_file}.bak.$(date +%Y%m%d%H%M%S)"
        mk_log "Created backup of existing SSH config" "false" "blue"
        
        # Ask if user wants to merge or replace
        read -p "Would you like to merge with (m) or replace (r) your existing SSH config? (m/r): " ssh_config_choice
        
        if [[ "$ssh_config_choice" == "m" ]]; then
            # Merge the configs - add new entries that don't exist
            mk_log "Merging SSH configurations..." "false" "blue"
            
            # Create temporary merge file
            local temp_file=$(mktemp)
            
            # Copy existing config to temp file
            cp "$dest_dir/$config_file" "$temp_file"
            
            # Extract host names from current config to avoid duplicates
            local existing_hosts=$(grep -E "^Host " "$dest_dir/$config_file" | awk '{print $2}')
            
            # Add hosts from source that don't exist in destination
            while IFS= read -r line; do
                if [[ "$line" =~ ^Host\ (.*)$ ]]; then
                    local host=${BASH_REMATCH[1]}
                    if ! echo "$existing_hosts" | grep -q "$host"; then
                        # Extract the entire host block and add it to temp file
                        sed -n "/^Host $host$/,/^$/p" "$source_dir/$config_file" >> "$temp_file"
                        echo "" >> "$temp_file"  # Add empty line after each host block
                    fi
                fi
            done < <(grep -E "^Host " "$source_dir/$config_file")
            
            # Copy merged file back to destination
            cp "$temp_file" "$dest_dir/$config_file"
            rm "$temp_file"
            
        elif [[ "$ssh_config_choice" == "r" ]]; then
            # Replace the existing config
            cp "$source_dir/$config_file" "$dest_dir/"
            mk_log "Replaced existing SSH config with new version" "false" "green"
        else
            mk_log "Invalid choice. SSH config not updated." "false" "red"
            return 1
        fi
    else
        # No existing config, just copy
        cp "$source_dir/$config_file" "$dest_dir/"
        mk_log "Copied SSH config to $dest_dir/$config_file" "false" "green"
    fi
    
    # Set proper permissions for SSH config
    chmod 600 "$dest_dir/$config_file"
    
    mk_log "SSH configuration complete. Your connections are now setup securely." "false" "green"
    return 0
}

# Function to install missing dependencies on Linux
install_linux_dependencies() {
    mk_log "Installing dependencies for Linux..." "false" "blue"
    
    # Check if Oh-My-Zsh is installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        mk_log "Installing Oh-My-Zsh..." "false" "yellow"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install required plugins
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        mk_log "Installing zsh-autosuggestions..." "false" "yellow"
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    fi
    
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        mk_log "Installing zsh-syntax-highlighting..." "false" "yellow"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    fi
    
    # Install Powerlevel10k theme
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        mk_log "Installing Powerlevel10k theme..." "false" "yellow"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    fi
    
    # Install JetBrainsMono Nerd Font
    if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNLNerdFont-Regular.ttf" ]; then
        mk_log "Installing JetBrainsMono Nerd Font..." "false" "yellow"
        mkdir -p ~/.local/share/fonts
        wget -q -P ~/.local/share/fonts \
          https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        cd ~/.local/share/fonts && unzip -q JetBrainsMono.zip && rm JetBrainsMono.zip
        fc-cache -fv > /dev/null 2>&1
        cd - > /dev/null
    fi
    
    mk_log "Linux dependencies installed successfully!" "false" "green"
    return 0
}

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Display welcome message
echo -e "\033[35m----------------------------------\033[0m"
echo -e "\033[35mWelcome to Personal ZSH Setup\033[0m"
echo -e "\033[35mDeveloped 06/2025 by Martin Balcewicz\033[0m"
echo -e "\033[35m(mail: martin.balcewicz@rockphysics.org)\033[0m"
echo -e "\033[35m----------------------------------\033[0m"
echo ""

# Detect operating system
OS_TYPE=$(detect_os)
mk_log "Detected operating system: $OS_TYPE" "false" "blue"

# Install dependencies based on OS
if [ "$OS_TYPE" = "linux" ]; then
    install_linux_dependencies
fi

# Check prerequisites
check_zsh
check_oh_my_zsh

# Confirm before proceeding
read -p "This script will set up your personal ZSH environment with modular alias files. Continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    mk_log "Setup cancelled by user." "false" "red"
    exit 0
fi

# Backup existing configuration
backup_zsh_config

# Copy all ZSH files to their destinations
copy_zsh_files

# Copy SSH config securely
copy_ssh_config

# Detect the operating system
os_type=$(detect_os)

# Install Linux dependencies if applicable
if [ "$os_type" == "linux" ]; then
    install_linux_dependencies
fi

mk_log "
Personal ZSH environment has been set up successfully!

Configuration files have been copied:
- Modular aliases -> ~/.oh-my-zsh/custom/
- Main config -> ~/.zshrc
- Prompt theme -> ~/.p10k.zsh
- SSH config handled.

To apply changes, run: exec zsh
" "true" "green"

echo ""
echo -e "\033[35m----------------------------------\033[0m"
echo -e "\033[35mPersonal ZSH Setup Complete!\033[0m"
echo -e "\033[35m----------------------------------\033[0m"
echo ""

# Instead of trying to source ZSH files from Bash, show instructions
echo -e "IMPORTANT: To apply changes, you need to:"
echo -e "1. Close this terminal window completely"
echo -e "2. Open a new terminal window, which will start ZSH with your new configuration"
echo -e "- OR -"
echo -e "Run the following command to switch to ZSH with your new settings:"
echo -e "    exec zsh"
echo ""
echo -e "To verify all configuration files are loaded, run:"
echo -e "    ls -la ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/*.zsh"
echo ""
