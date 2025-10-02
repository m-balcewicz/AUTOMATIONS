#!/bin/bash
# Quick fix script to install Oh-My-Zsh on Linux system

echo "Installing Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

if [ $? -eq 0 ]; then
    echo "✓ Oh-My-Zsh installed successfully!"
    echo ""
    echo "Now you can run: exec zsh"
    echo "Your personal configuration should work properly."
else
    echo "❌ Oh-My-Zsh installation failed!"
    echo "Please check your internet connection and try again."
fi
