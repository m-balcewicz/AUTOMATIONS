#!/bin/bash
# ---------------------------------------
# configure_directory_display.sh
# Interactive script to configure directory display in prompt
# ---------------------------------------

echo "🎨 Directory Display Configuration"
echo "=================================="
echo ""
echo "Current prompt shows full path: ~/Data/CODING_WORLD/AUTOMATIONS"
echo ""
echo "Choose your preferred directory display:"
echo ""
echo "1) Show only current folder name (AUTOMATIONS)"
echo "2) Show last 2 folders (CODING_WORLD/AUTOMATIONS)" 
echo "3) Show abbreviated path (~/...NG_WORLD/AUTOMATIONS)"
echo "4) Remove directory from prompt entirely"
echo "5) Keep current full path display"
echo ""

read -p "Enter your choice [1-5]: " choice

case $choice in
    1)
        echo "Setting up: Show only current folder name..."
        # Update p10k config for folder name only
        sed -i.bak 's/typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=.*/typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last/' ~/.p10k.zsh 2>/dev/null || true
        sed -i.bak 's/typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=.*/typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1/' ~/.p10k.zsh 2>/dev/null || true
        echo "✓ Directory will show only current folder name"
        ;;
    2)
        echo "Setting up: Show last 2 folders..."
        sed -i.bak 's/typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=.*/typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_from_right/' ~/.p10k.zsh 2>/dev/null || true
        sed -i.bak 's/typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=.*/typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2/' ~/.p10k.zsh 2>/dev/null || true
        echo "✓ Directory will show last 2 folder names"
        ;;
    3)
        echo "Setting up: Show abbreviated path..."
        sed -i.bak 's/typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=.*/typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_middle/' ~/.p10k.zsh 2>/dev/null || true
        sed -i.bak 's/typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=.*/typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3/' ~/.p10k.zsh 2>/dev/null || true
        echo "✓ Directory will show abbreviated path"
        ;;
    4)
        echo "Setting up: Remove directory from prompt..."
        # Comment out dir in LEFT_PROMPT_ELEMENTS
        sed -i.bak 's/    dir/#    dir/' ~/.p10k.zsh 2>/dev/null || true
        echo "✓ Directory removed from prompt"
        ;;
    5)
        echo "Keeping current full path display..."
        echo "✓ No changes made"
        ;;
    *)
        echo "Invalid choice. No changes made."
        exit 1
        ;;
esac

echo ""
echo "🔄 To apply changes, restart your shell:"
echo "   exec zsh"
echo ""
echo "💡 To reconfigure anytime:"
echo "   ./utils/configure_directory_display.sh"
