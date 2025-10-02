#!/bin/bash
# ---------------------------------------
# fix_lsd_aliases.sh
# Fix lsd-dependent aliases when lsd is not installed
# ---------------------------------------

echo "🔧 Fixing lsd-dependent aliases..."

# Check if lsd is installed
if command -v lsd &> /dev/null; then
    echo "✓ lsd is installed and working"
    exit 0
fi

echo "⚠️  lsd not found - fixing aliases to use standard ls"

# Check current shell
if [[ -n "$ZSH_VERSION" ]]; then
    # We're in ZSH
    echo "🐚 Detected ZSH shell"
    
    # Unset problematic aliases
    unalias ls 2>/dev/null || true
    unalias ll 2>/dev/null || true  
    unalias la 2>/dev/null || true
    
    # Set appropriate aliases based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        alias ls='ls -G'
        alias ll='ls -alh -G'
        alias la='ls -lah -G'
        echo "✓ Set macOS-compatible ls aliases"
    else
        # Linux
        alias ls='ls --color=auto'
        alias ll='ls -alh --color=auto'
        alias la='ls -lah --color=auto'
        echo "✓ Set Linux-compatible ls aliases"
    fi
    
elif [[ -n "$BASH_VERSION" ]]; then
    # We're in Bash
    echo "🐚 Detected Bash shell"
    
    # Unset problematic aliases
    unalias ls 2>/dev/null || true
    unalias ll 2>/dev/null || true
    unalias la 2>/dev/null || true
    
    # Set appropriate aliases based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        alias ls='ls -G'
        alias ll='ls -alh -G'
        alias la='ls -lah -G'
        echo "✓ Set macOS-compatible ls aliases"
    else
        # Linux
        alias ls='ls --color=auto'
        alias ll='ls -alh --color=auto'
        alias la='ls -lah --color=auto'
        echo "✓ Set Linux-compatible ls aliases"
    fi
fi

echo ""
echo "🎯 Quick fix applied! Your ls commands should work now."
echo ""
echo "💡 To install lsd for better file listing:"
echo "   On Ubuntu/Debian: sudo apt install lsd"
echo "   On CentOS/RHEL:   sudo yum install lsd"
echo "   On Fedora:        sudo dnf install lsd"
echo "   On macOS:         brew install lsd"
echo ""
echo "🔄 To apply the permanent fix, restart your shell:"
echo "   exec zsh"
