#!/bin/bash
# Quick fix to add error handling to .zshrc

echo "🔧 Adding error handling to .zshrc..."

# Backup current .zshrc
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)

# Create a more robust .zshrc
cat > ~/.zshrc << 'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Check if Oh-My-Zsh is installed
if [[ ! -d "$ZSH" ]]; then
    echo "Oh-My-Zsh not found at $ZSH"
    echo "Please run: sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
    return
fi

# ZSH Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-My-ZSH Plugins (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS with Homebrew
    plugins=(git brew zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-completions)
else
    # Linux and other systems
    plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-completions)
fi

# Source Oh-My-ZSH with error handling
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
else
    echo "Error: $ZSH/oh-my-zsh.sh not found"
    echo "Please reinstall Oh-My-Zsh"
fi

# Basic cross-platform aliases that should work everywhere
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias la='ls -lah'
alias ll='ls -alh'
alias l='ls -lh'

# Load custom aliases if they exist
if [[ -d "$ZSH/custom" ]]; then
    for file in "$ZSH/custom"/*.zsh; do
        [[ -r "$file" ]] && source "$file"
    done
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "✓ Created robust .zshrc with error handling"
echo "✓ Backup saved as ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
echo ""
echo "Now try: exec zsh"
