# 🛠️ Troubleshooting Guide

This document covers common issues encountered during the setup process and their solutions.

## 📋 Table of Contents

1. [Common Issues](#common-issues)
2. [Error Types](#error-types)
3. [Quick Fixes](#quick-fixes)
4. [Prevention Tips](#prevention-tips)
5. [Advanced Troubleshooting](#advanced-troubleshooting)

## 🚨 Common Issues

### 1. Oh-My-Zsh Installation Issues

#### **Error**: `no such file or directory: ~/.oh-my-zsh/oh-my-zsh.sh`
```bash
/mnt/NEUTRON/home/user/.zshrc:source:22: no such file or directory: /mnt/NEUTRON/home/user/.oh-my-zsh/oh-my-zsh.sh
```

**Symptoms:**
- Shell fails to load properly after `exec zsh`
- Setup reports "Oh-My-Zsh already installed" but files are missing
- ZSH configuration cannot source Oh-My-Zsh

**Root Cause:**
- Incomplete Oh-My-Zsh installation
- Corrupted installation files
- Missing core Oh-My-Zsh components

**Solution:**
```bash
# Use the complete reinstall utility
./utils/fix_ohmyzsh_reinstall.sh
```

### 2. Syntax Errors in Installation Scripts

#### **Error**: `syntax error near unexpected token 'elif'`
```bash
./data/install_powerlevel10k.sh: line 26: syntax error near unexpected token 'elif'
./data/install_powerlevel10k.sh: line 26: `        elif [ "$style" == "decorative" ]; then'
```

**Symptoms:**
- Installation scripts fail with syntax errors
- Broken conditional statements in shell scripts
- Steps 3 and 4 of complete setup fail

**Root Cause:**
- Incomplete code replacement during script updates
- Orphaned utility function remnants
- Mismatched if/fi statements

**Solution:**
- Fixed scripts have been provided with clean implementations
- Scripts now use proper fallback functions

### 3. Personal Configuration Issues

#### **Error**: `local: can only be used in a function`
```bash
/path/to/setup_personal_env.sh: line 101: local: can only be used in a function
```

**Symptoms:**
- Personal environment setup fails
- Backup creation errors
- Configuration files not copied properly

**Root Cause:**
- Duplicate function definitions
- Local variable declarations outside functions
- Malformed script structure

**Solution:**
- Use the robust zshrc configuration utility
- Scripts have been rewritten with proper function structure

### 4. Cross-Platform Compatibility Issues

#### **Error**: `no such file or directory: /opt/homebrew/bin/brew`
```bash
/home/user/.oh-my-zsh/custom/macos.zsh:13: no such file or directory: /opt/homebrew/bin/brew
```

**Symptoms:**
- macOS-specific commands failing on Linux
- Homebrew commands not found on non-macOS systems
- Platform-specific aliases causing errors

**Root Cause:**
- macOS aliases loaded on Linux systems
- Missing OS detection in alias files
- Lack of platform-specific handling

**Solution:**
```bash
# The fix scripts now include proper OS-specific handling
# macOS aliases are disabled on Linux systems
```

## 🔧 Error Types

### Script Syntax Errors
- **Pattern**: `syntax error near unexpected token`
- **Cause**: Broken conditional statements, incomplete code replacements
- **Fix**: Use the provided fixed scripts in `data/` directory

### Missing Dependencies
- **Pattern**: `command not found` or `no such file or directory`
- **Cause**: Oh-My-Zsh, plugins, or themes not properly installed
- **Fix**: Run complete reinstallation utilities

### Configuration Errors
- **Pattern**: `local: can only be used in a function`
- **Cause**: Malformed function definitions, duplicate code
- **Fix**: Use robust configuration scripts

### Path Issues
- **Pattern**: Incorrect file paths, missing directories
- **Cause**: Case sensitivity (DATA vs data), missing directory updates
- **Fix**: Ensure consistent lowercase naming

## 🚀 Quick Fixes

### Emergency Shell Reset
If your shell is completely broken:
```bash
# Switch back to bash temporarily
bash

# Run the complete fix
./utils/fix_ohmyzsh_reinstall.sh

# Try zsh again
exec zsh
```

### Rapid Diagnosis
```bash
# Check Oh-My-Zsh installation
ls -la ~/.oh-my-zsh/

# Verify core file exists
ls -la ~/.oh-my-zsh/oh-my-zsh.sh

# Test zshrc syntax
zsh -n ~/.zshrc

# Check plugin directories
ls -la ~/.oh-my-zsh/custom/plugins/
```

### Plugin Verification
```bash
# Check installed plugins
ls ~/.oh-my-zsh/custom/plugins/

# Expected plugins:
# - zsh-autosuggestions
# - zsh-syntax-highlighting  
# - you-should-use
# - zsh-completions
```

## 🛡️ Prevention Tips

### 1. Pre-Installation Checks
```bash
# Verify git is installed
git --version

# Check curl availability
curl --version

# Ensure proper permissions
ls -la ~/
```

### 2. Use Complete Setup
```bash
# Always use option 1 for new systems
./setup.sh
# Choose: 1) Complete Setup (Recommended)
```

### 3. Backup Before Changes
```bash
# Manual backup of current config
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
```

### 4. OS-Specific Considerations

#### Linux Systems
- Ensure package managers are available (apt, yum, dnf)
- Check internet connectivity for git clones
- Verify write permissions in home directory

#### macOS Systems  
- Install Xcode Command Line Tools first
- Homebrew should be installed for optimal experience

## 🔍 Advanced Troubleshooting

### Debug Mode
Enable verbose output for troubleshooting:
```bash
export DEBUG=1
./setup.sh
```

### Manual Oh-My-Zsh Installation
If automated installation fails:
```bash
# Manual installation
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins manually
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

### Permission Issues
```bash
# Fix ownership if needed
sudo chown -R $(whoami):$(whoami) ~/.oh-my-zsh

# Set proper permissions
chmod -R 755 ~/.oh-my-zsh
```

### Network Issues
```bash
# Test GitHub connectivity
curl -I https://github.com

# Use SSH instead of HTTPS if needed
git config --global url."ssh://git@github.com/".insteadOf "https://github.com/"
```

## 📞 Getting Help

### Log Collection
When reporting issues, include:
```bash
# System information
uname -a
echo $OSTYPE

# ZSH version
zsh --version

# Oh-My-Zsh status
ls -la ~/.oh-my-zsh/

# Plugin status
ls -la ~/.oh-my-zsh/custom/plugins/

# Current shell configuration
head -20 ~/.zshrc
```

### Useful Commands for Diagnosis
```bash
# Check current shell
echo $SHELL

# Verify ZSH installation
which zsh

# Test plugin loading
zsh -c "source ~/.zshrc && echo 'ZSH loaded successfully'"
```

## 🎯 Success Indicators

After successful setup, you should see:
- ✅ Beautiful Powerlevel10k prompt with git integration
- ✅ Smart autosuggestions as you type
- ✅ Syntax highlighting for commands
- ✅ All custom aliases working (`ll`, `gs`, `repos`, etc.)
- ✅ No error messages during shell startup

---

*This troubleshooting guide is based on real issues encountered during cross-platform deployment and testing.*
