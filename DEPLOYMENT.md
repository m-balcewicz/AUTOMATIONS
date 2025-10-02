# 🚀 Deployment Guide

This guide provides step-by-step instructions for deploying the development environment automation suite on new systems.

## 📋 Prerequisites

### System Requirements
- **Operating System**: macOS, Linux (Ubuntu/Debian/CentOS/Fedora/Arch), or Synology NAS
- **Internet Connection**: Required for downloading components
- **Terminal Access**: Command-line interface access
- **User Permissions**: Ability to install software and modify shell configuration

### Pre-Installation Checklist
- [ ] Backup existing shell configurations (`.zshrc`, `.bashrc`, etc.)
- [ ] Ensure you have sudo/admin privileges if needed
- [ ] Check available disk space (minimum 500MB recommended)
- [ ] Verify internet connectivity for downloads

## 🎯 Deployment Methods

### Method 1: Git Clone (Recommended)
```bash
# Clone the repository
git clone <repository-url> ~/automations
cd ~/automations

# Make scripts executable
chmod +x setup.sh
chmod +x data/*.sh
chmod +x personal/*.sh
chmod +x utils/*.sh

# Run the setup
./setup.sh
```

### Method 2: Direct Download
```bash
# Download and extract the archive
wget <archive-url> -O automations.zip
unzip automations.zip
cd automations

# Make scripts executable
find . -name "*.sh" -exec chmod +x {} \;

# Run the setup
./setup.sh
```

### Method 3: Manual Transfer
```bash
# After transferring files via SCP, USB, etc.
cd /path/to/automations

# Ensure all scripts are executable
chmod +x setup.sh
chmod +x data/*.sh
chmod +x personal/*.sh
chmod +x utils/*.sh

# Run the setup
./setup.sh
```

## 🔧 Installation Options

### Complete Installation (New System)
For a fresh system or complete setup:

```bash
./setup.sh
# Select option 1: "Complete Development Environment Setup"
```

This will install:
- ZSH shell
- Oh-My-Zsh framework
- Powerlevel10k theme
- Essential plugins
- Nerd Fonts
- Neovim editor
- Personal configurations
- Custom aliases

### Personal Environment Only
If you already have ZSH and Oh-My-Zsh installed:

```bash
cd personal
./setup_personal_env.sh
```

This will install:
- Personal configurations
- Custom aliases
- SSH configurations
- Theme customizations

### Individual Component Installation
Install specific components as needed:

```bash
# Install Oh-My-Zsh framework
./data/install_oh_my_zsh.sh

# Install Powerlevel10k theme
./data/install_powerlevel10k.sh

# Install ZSH plugins
./data/install_zsh_plugins.sh

# Install Nerd Fonts
./data/install_fonts.sh

# Install Neovim
./data/install_neovim.sh
```

## 🌍 Platform-Specific Instructions

### macOS Deployment
```bash
# Ensure Xcode Command Line Tools are installed
xcode-select --install

# Run the automation
./setup.sh

# Homebrew will be automatically installed if needed
```

### Linux Deployment (Ubuntu/Debian)
```bash
# Update package list
sudo apt update

# Run the automation
./setup.sh

# Package manager will be automatically detected
```

### Linux Deployment (CentOS/RHEL/Fedora)
```bash
# Update package list
sudo yum update  # or dnf update for Fedora

# Run the automation
./setup.sh

# Package manager will be automatically detected
```

### Synology NAS Deployment
```bash
# SSH into your Synology NAS
ssh admin@your-nas-ip

# Navigate to a suitable directory
cd /volume1/homes/your-username

# Run the automation
./setup.sh

# Note: Some features may have limited functionality on DSM
```

## 🔍 Post-Installation Verification

### Test Shell Environment
```bash
# Open a new terminal session or source the configuration
source ~/.zshrc

# Verify ZSH is active
echo $SHELL

# Test custom aliases
ll              # Should show detailed file listing
repos           # Should navigate to repositories directory
sysinfo         # Should display system information
```

### Verify Theme and Fonts
```bash
# Check Powerlevel10k theme is active
echo $ZSH_THEME

# Test special characters (should display correctly with Nerd Fonts)
echo "   "

# Verify git integration (in a git repository)
git status      # Should show enhanced git prompt
```

### Test Plugin Functionality
```bash
# Test autosuggestions (start typing a command you've used before)
# Should show gray text suggestion

# Test syntax highlighting (type a command)
# Should show green for valid commands, red for invalid

# Test you-should-use plugin
ls              # Should suggest using 'll' alias if available
```

## 🚨 Troubleshooting Deployment Issues

### Installation Fails
```bash
# Check for detailed troubleshooting
cat TROUBLESHOOTING.md

# Run diagnostic utility
./utils/fix_zsh_diagnosis.sh

# For Oh-My-Zsh issues
./utils/fix_ohmyzsh_reinstall.sh
```

### Permission Issues
```bash
# Fix script permissions
find . -name "*.sh" -exec chmod +x {} \;

# Fix directory permissions
chmod 755 data/ personal/ utils/
```

### Network Issues
```bash
# Test connectivity
ping github.com

# Use alternative download method
export USE_MIRROR=true
./setup.sh
```

## 🔄 Updating Existing Installation

### Update All Components
```bash
# Pull latest changes (if using git)
git pull

# Re-run setup to update components
./setup.sh

# Select option 6: "Update existing installation"
```

### Update Specific Components
```bash
# Update Oh-My-Zsh
$ZSH/tools/upgrade.sh

# Update Powerlevel10k
git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull

# Update plugins
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
```

## 📦 Backup and Restore

### Create Backup Before Installation
```bash
# Backup existing configurations
mkdir ~/shell_backup_$(date +%Y%m%d)
cp ~/.zshrc ~/shell_backup_$(date +%Y%m%d)/ 2>/dev/null || true
cp ~/.bashrc ~/shell_backup_$(date +%Y%m%d)/ 2>/dev/null || true
cp -r ~/.oh-my-zsh ~/shell_backup_$(date +%Y%m%d)/ 2>/dev/null || true
```

### Restore Previous Configuration
```bash
# Restore from backup
cp ~/shell_backup_YYYYMMDD/.zshrc ~/
cp ~/shell_backup_YYYYMMDD/.bashrc ~/
cp -r ~/shell_backup_YYYYMMDD/.oh-my-zsh ~/

# Reload shell
source ~/.zshrc
```

## 🎯 Deployment Validation

### Automated Validation
```bash
# Run the validation script
./utils/demo_utils.sh

# Check all components are working
./utils/test_personal_setup.sh
```

### Manual Validation Checklist
- [ ] ZSH is the default shell
- [ ] Oh-My-Zsh is installed and functioning
- [ ] Powerlevel10k theme is active and displaying correctly
- [ ] Plugins are loaded (autosuggestions, syntax highlighting)
- [ ] Custom aliases are available
- [ ] Nerd Fonts are displaying special characters
- [ ] Git integration is working in repositories
- [ ] Conda environment detection (if applicable)
- [ ] SSH configurations are in place

## 📈 Performance Optimization

### Shell Startup Time
```bash
# Measure shell startup time
time zsh -i -c exit

# If slow, check for issues
./utils/fix_zsh_diagnosis.sh
```

### Plugin Optimization
```bash
# Disable unused plugins in ~/.zshrc
# Remove plugins from the plugins array that you don't use

# Restart shell to apply changes
exec zsh
```

## 🔐 Security Considerations

### SSH Configuration
```bash
# Verify SSH configurations are secure
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_* 2>/dev/null || true
chmod 644 ~/.ssh/*.pub 2>/dev/null || true
chmod 644 ~/.ssh/config 2>/dev/null || true
```

### File Permissions
```bash
# Ensure proper permissions on shell files
chmod 644 ~/.zshrc
chmod 644 ~/.p10k.zsh
chmod 755 ~/.oh-my-zsh
```

## 🎊 Deployment Complete

Your development environment automation is now successfully deployed! 

### Next Steps
1. **Customize**: Modify aliases and configurations in `personal/aliases/`
2. **Extend**: Add new tools to the `data/` directory
3. **Share**: Use this setup on additional systems
4. **Maintain**: Regularly update components using the update procedures

### Getting Help
- Check `TROUBLESHOOTING.md` for common issues
- Use the automated fix utilities in `utils/`
- Review the main `README.md` for detailed usage information

---

**Happy coding with your new development environment! 🚀**
