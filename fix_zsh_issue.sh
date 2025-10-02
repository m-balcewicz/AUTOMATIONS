#!/bin/bash
# Quick fix for Oh-My-Zsh issue on Linux system

echo "🔍 Diagnosing Oh-My-Zsh installation..."

# Check if Oh-My-Zsh directory exists
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✓ Oh-My-Zsh directory exists at $HOME/.oh-my-zsh"
else
    echo "❌ Oh-My-Zsh directory NOT found at $HOME/.oh-my-zsh"
    echo "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Check if oh-my-zsh.sh exists
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "✓ oh-my-zsh.sh exists"
else
    echo "❌ oh-my-zsh.sh NOT found"
    echo "Reinstalling Oh-My-Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Check current ZSH variable
echo "Current \$ZSH variable: ${ZSH:-NOT SET}"
echo "Expected location: $HOME/.oh-my-zsh"

# Verify .zshrc content
echo ""
echo "Checking .zshrc configuration..."
if grep -q "export ZSH=" "$HOME/.zshrc"; then
    echo "✓ ZSH variable is exported in .zshrc"
    grep "export ZSH=" "$HOME/.zshrc"
else
    echo "❌ ZSH variable not found in .zshrc"
    echo "Adding ZSH variable to .zshrc..."
    sed -i '1i export ZSH="$HOME/.oh-my-zsh"' "$HOME/.zshrc"
fi

# Test sourcing
echo ""
echo "Testing Oh-My-Zsh sourcing..."
if ZSH="$HOME/.oh-my-zsh" source "$HOME/.oh-my-zsh/oh-my-zsh.sh" 2>/dev/null; then
    echo "✓ Oh-My-Zsh can be sourced successfully"
else
    echo "❌ Oh-My-Zsh sourcing failed"
fi

echo ""
echo "Diagnosis complete. Try running: exec zsh"
