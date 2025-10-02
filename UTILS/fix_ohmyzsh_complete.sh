#!/bin/bash
# Complete Oh-My-Zsh reinstallation for Linux

echo "🔧 Completely reinstalling Oh-My-Zsh on Linux..."

# Remove any existing Oh-My-Zsh installation
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "🗑️ Removing existing Oh-My-Zsh installation..."
    rm -rf "$HOME/.oh-my-zsh"
fi

# Install Oh-My-Zsh fresh
echo "📦 Installing Oh-My-Zsh..."
RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Verify installation
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "✅ Oh-My-Zsh installed successfully!"
else
    echo "❌ Oh-My-Zsh installation failed!"
    exit 1
fi

# Reinstall plugins
echo "🔌 Reinstalling ZSH plugins..."

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# you-should-use
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/you-should-use" ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use "$HOME/.oh-my-zsh/custom/plugins/you-should-use"
fi

# zsh-completions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
fi

# Reinstall Powerlevel10k theme
echo "🎨 Reinstalling Powerlevel10k theme..."
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

# Fix the macOS aliases issue by creating a Linux-only version
echo "🐧 Fixing Linux-specific alias loading..."
if [ -f "$HOME/.oh-my-zsh/custom/macos.zsh" ]; then
    # Replace macOS aliases with empty file for Linux
    cat > "$HOME/.oh-my-zsh/custom/macos.zsh" << 'EOF'
# macOS aliases - disabled on Linux
# This file prevents errors when loading aliases on Linux systems
echo "ℹ️ macOS aliases skipped (running on Linux)"
EOF
fi

echo ""
echo "✅ Complete Oh-My-Zsh reinstallation finished!"
echo ""
echo "Now try: exec zsh"
