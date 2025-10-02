#!/bin/bash
# ---------------------------------------
# Script: install_jetbrains_mono_nerd_font.sh
# Author: Martin Balcewicz
# Email: martin.balcewicz@rockphysics.org
# Date: June 2025
# Description: Installs JetBrains Mono Nerd Font for macOS
# ---------------------------------------

# Source the shell utilities
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
UTILS_PATH="${SCRIPT_DIR}/../UTILS/shell_utils.sh"

# Source the utilities file or use local fallback implementations
if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    echo "Warning: Could not find shell utilities at $UTILS_PATH"
    echo "Using local function implementations instead."
    
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
        
        # Define ANSI color codes
        local GREEN="\033[32m"
        local RED="\033[31m"
        local DEFAULT="\033[0m"
        
        # Set the color based on the parameter
        local selected_color="$DEFAULT"
        if [ "$color" == "green" ]; then
            selected_color="$GREEN"
        elif [ "$color" == "red" ]; then
            selected_color="$RED"
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

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        mk_log "This script is for macOS only. Exiting." "false" "red"
        exit 1
    fi
}

# Function to check if JetBrains Mono Nerd Font is installed
check_font_installed() {
    # Check in the user's font directory
    if find ~/Library/Fonts -name "JetBrainsMono*Nerd*Font*.ttf" -o -name "JetBrainsMono*Nerd*Font*.otf" 2>/dev/null | grep -q .; then
        return 0
    fi
    
    # Check in the system font directory
    if find /Library/Fonts -name "JetBrainsMono*Nerd*Font*.ttf" -o -name "JetBrainsMono*Nerd*Font*.otf" 2>/dev/null | grep -q .; then
        return 0
    fi
    
    return 1
}

# Function to download and install JetBrains Mono Nerd Font
install_font() {
    # Create a temporary directory
    local temp_dir=$(mktemp -d)
    mk_log "Created temporary directory: $temp_dir" "false" "default"
    
    # Download the font zip file
    mk_log "Downloading JetBrains Mono Nerd Font..." "false" "green"
    curl -fsSL -o "$temp_dir/jetbrains-mono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
    
    if [ $? -ne 0 ]; then
        mk_log "Failed to download the font. Please check your internet connection." "false" "red"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extract the zip file
    mk_log "Extracting font files..." "false" "green"
    unzip -q "$temp_dir/jetbrains-mono.zip" -d "$temp_dir/fonts"
    
    if [ $? -ne 0 ]; then
        mk_log "Failed to extract the font files." "false" "red"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Create fonts directory if it doesn't exist
    mkdir -p ~/Library/Fonts
    
    # Copy font files to the user's fonts directory
    mk_log "Installing font files..." "false" "green"
    cp "$temp_dir/fonts/"*.ttf ~/Library/Fonts/ 2>/dev/null
    cp "$temp_dir/fonts/"*.otf ~/Library/Fonts/ 2>/dev/null
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Verify installation
    if check_font_installed; then
        return 0
    else
        return 1
    fi
}

# Function to detect terminal emulator
detect_terminal() {
    # Check for iTerm
    if [[ -n "$ITERM_SESSION_ID" ]]; then
        echo "iTerm2"
        return
    fi
    
    # Check for macOS Terminal
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        echo "Apple_Terminal"
        return
    fi
    
    # Default case
    echo "unknown"
}

# Function to set Terminal.app font using AppleScript
set_terminal_font() {
    local font_name="$1"
    local font_size="$2"
    
    # Create a temporary AppleScript file
    local temp_script=$(mktemp)
    
    # Write the AppleScript to set the Terminal font
    cat > "$temp_script" <<EOT
tell application "Terminal"
    set targetFont to "$font_name"
    set targetSize to $font_size
    
    -- Get the default settings
    set targetSettings to default settings
    
    -- Set the font
    set font name of targetSettings to targetFont
    set font size of targetSettings to targetSize
    
    -- Also update current window if Terminal is open
    if (count of windows) > 0 then
        set current settings of selected tab of front window to targetSettings
    end if
end tell
EOT
    
    # Execute the AppleScript
    osascript "$temp_script"
    local result=$?
    
    # Remove the temporary file
    rm "$temp_script"
    
    return $result
}

# Function to configure ZSH with the font
configure_zsh_with_font() {
    mk_log "Configuring ZSH to work with JetBrains Mono Nerd Font..." "false" "green"
    
    # Check if .zshrc exists
    if [ ! -f "$HOME/.zshrc" ]; then
        mk_log "No .zshrc file found. Creating one..." "false" "default"
        touch "$HOME/.zshrc"
    fi
    
    # Check if using Oh-My-ZSH
    if [ -d "$HOME/.oh-my-zsh" ]; then
        mk_log "Oh-My-ZSH detected!" "false" "green"
        
        # Inform about Powerlevel10k
        mk_log "
JetBrains Mono Nerd Font works great with Powerlevel10k theme!
You can install Powerlevel10k using our dedicated installer:
./install_powerlevel10k.sh
" "true" "green"
    else
        # If not using Oh-My-ZSH, add a basic prompt that works well with Nerd Fonts
        if ! grep -q "# Nerd Font configuration" "$HOME/.zshrc"; then
            read -p "Would you like to add a simple Nerd Font compatible prompt to your .zshrc? (y/n): " add_prompt
            if [[ "$add_prompt" =~ ^[Yy]$ ]]; then
                echo "" >> "$HOME/.zshrc"
                echo "# Nerd Font configuration (added by install_jetbrains_mono_nerd_font.sh)" >> "$HOME/.zshrc"
                echo "PROMPT='%F{green}%n@%m%f %F{blue}%~%f %# '" >> "$HOME/.zshrc"
                mk_log "Basic prompt configuration added to .zshrc" "false" "green"
            else
                mk_log "Skipping prompt configuration." "false" "default"
            fi
        fi
    fi
}

# Function to configure the terminal emulator to use the font
configure_terminal_with_font() {
    local terminal_type=$(detect_terminal)
    
    case "$terminal_type" in
        "iTerm2")
            mk_log "Detected iTerm2 terminal. Applying font settings..." "false" "green"
            
            read -p "Would you like to set JetBrains Mono Nerd Font as default for iTerm2? (y/n): " set_iterm_font
            if [[ "$set_iterm_font" =~ ^[Yy]$ ]]; then
                # iTerm2 doesn't have a simple command-line API for changing fonts
                # We'll provide instructions instead
                mk_log "
To set JetBrains Mono Nerd Font in iTerm2:
1. Open iTerm2 Preferences (Cmd+,)
2. Go to Profiles > Text
3. Select 'JetBrainsMono Nerd Font' from the Font dropdown
4. Set your preferred size (recommended: 12pt)

We recommend creating a new profile with these settings.
" "true" "green"
            fi
            ;;
            
        "Apple_Terminal")
            mk_log "Detected macOS Terminal. Applying font settings..." "false" "green"
            
            read -p "Would you like to set JetBrains Mono Nerd Font as default for Terminal.app? (y/n): " set_term_font
            if [[ "$set_term_font" =~ ^[Yy]$ ]]; then
                # Ask for font size
                read -p "Enter preferred font size (default: 12): " font_size
                font_size=${font_size:-12}
                
                # Set the font using our AppleScript function
                if set_terminal_font "JetBrainsMono Nerd Font" "$font_size"; then
                    mk_log "
Font settings successfully applied to Terminal.app!
Font: JetBrainsMono Nerd Font
Size: ${font_size}pt

Note: These settings are applied immediately to open windows.
For best results, restart Terminal.app after installation.
" "true" "green"
                else
                    mk_log "
Failed to set Terminal.app font automatically.

You can manually set the font:
1. Open Terminal → Preferences → Profiles
2. Select your profile → Text tab
3. Click 'Change...' next to font
4. Select 'JetBrainsMono Nerd Font' and size ${font_size}
" "true" "red"
                fi
            fi
            ;;
            
        *)
            mk_log "
We couldn't automatically configure your terminal.
Please manually set JetBrains Mono Nerd Font in your terminal's preferences.
" "true" "default"
            ;;
    esac
}

# Display welcome message
echo -e "\033[32m----------------------------------"
echo -e "Welcome to JetBrains Mono Nerd Font Installer"
echo -e "Developed 06/2025 by Martin Balcewicz"
echo -e "(mail: martin.balcewicz@rockphysics.org)"
echo -e "----------------------------------\033[0m"
echo ""

# Check if running on macOS
check_macos

# Check if the font is already installed
if check_font_installed; then
    mk_log "
JetBrains Mono Nerd Font is already installed!

You can use this font in your terminal and code editor.
" "true" "green"

    # Offer configuration options even if font is already installed
    # Configure ZSH if it's the current shell
    if [[ "$SHELL" == */zsh ]]; then
        read -p "Would you like to configure ZSH to utilize the Nerd Font capabilities? (y/n): " configure_zsh
        if [[ "$configure_zsh" =~ ^[Yy]$ ]]; then
            configure_zsh_with_font
        fi
    fi
    
    # Configure the terminal emulator
    read -p "Would you like to set the font as default in your terminal? (y/n): " configure_terminal
    if [[ "$configure_terminal" =~ ^[Yy]$ ]]; then
        configure_terminal_with_font
    fi
else
    # Ask if user wants to install the font
    read -p "JetBrains Mono Nerd Font is not installed. Do you want to install it now? (y/n): " install_choice
    
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        if install_font; then
            mk_log "
JetBrains Mono Nerd Font has been successfully installed!

You can now use this font in your terminal and code editor.
" "true" "green"
            
            # Configure ZSH if it's the current shell
            if [[ "$SHELL" == */zsh ]]; then
                read -p "Would you like to configure ZSH to utilize the Nerd Font capabilities? (y/n): " configure_zsh
                if [[ "$configure_zsh" =~ ^[Yy]$ ]]; then
                    configure_zsh_with_font
                fi
            fi
            
            # Configure the terminal emulator
            read -p "Would you like to set the font as default in your terminal? (y/n): " configure_terminal
            if [[ "$configure_terminal" =~ ^[Yy]$ ]]; then
                configure_terminal_with_font
            fi
            
        else
            mk_log "
Failed to install JetBrains Mono Nerd Font. Please try again later or install manually:
1. Go to https://www.nerdfonts.com/font-downloads
2. Download JetBrains Mono Nerd Font
3. Extract and move .ttf files to ~/Library/Fonts/
" "true" "red"
            exit 1
        fi
    else
        mk_log "Installation cancelled by user." "false" "red"
        exit 0
    fi
fi

# Show usage instructions
mk_log "
How to use JetBrains Mono Nerd Font:

Terminal (iTerm2):
1. Open Preferences → Profiles → Text
2. Select 'JetBrainsMono Nerd Font' from Font dropdown

VS Code:
1. Open Settings (Cmd+,)
2. Search for 'Font Family'
3. Set to: 'JetBrainsMono Nerd Font', monospace

Neovim:
In your init.vim or init.lua, add:
vim.opt.guifont = 'JetBrainsMono Nerd Font:h12'
" "true" "green"

# Add Next Steps section
echo ""
echo -e "\033[32m----------------------------------"
echo -e "Next Steps After Installation:"
echo -e "----------------------------------\033[0m"
echo ""

# General next steps
echo "1. Close this terminal window completely"
echo "2. Open a new terminal window to see your new font in action"
echo ""

echo -e "\033[32mAdditional Enhancements:\033[0m"
echo "• To install Powerlevel10k theme for a beautiful ZSH prompt with icons:"
echo "  ./install_powerlevel10k.sh"
echo ""
echo "• Install 'lsd' or 'exa' for enhanced directory listings with icons:"
echo "  brew install lsd"
echo ""
echo "• Configure 'ls' aliases in your .zshrc:"
echo "  alias ls='lsd'"
echo "  alias ll='lsd -la'"
echo ""
echo "• For VS Code, install these extensions to work with Nerd Fonts:"
echo "  - 'Material Icon Theme'"
echo "  - 'Better Comments'"
echo ""

echo -e "\033[32m----------------------------------"
echo -e "JetBrains Mono Nerd Font Setup Complete!"
echo -e "----------------------------------\033[0m"
echo ""
