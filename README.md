# 🚀 Development Environment Automation

A comprehensive, cross-platform automation suite for setting up a modern development environment with ZSH, Oh-My-Zsh, custom themes, and personal configurations.

## 🎯 Features

- **Cross-Platform Support**: Works on macOS, Linux, and Synology NAS
- **Modular Architecture**: Individual components can be installed separately
- **Personal Configurations**: Custom aliases, themes, and SSH configs
- **Automated Dependencies**: Handles font installation, plugins, and themes
- **Backup System**: Automatically backs up existing configurations
- **Interactive Setup**: Menu-driven installation process

## 📁 Project Structure

```
AUTOMATIONS/
├── setup.sh                    # 🎮 Master setup script (START HERE)
├── README.md                   # 📖 This documentation
├── data/                       # 🔧 Installation tools
│   ├── detect_os.sh            # 🔍 OS detection utility
│   ├── install_oh_my_zsh.sh    # 💻 Oh-My-Zsh installer
│   ├── install_fonts.sh        # 🔤 Nerd Fonts installer
│   ├── install_powerlevel10k.sh # 🎨 P10k theme installer
│   ├── install_zsh_plugins.sh  # 🔌 ZSH plugins installer
│   ├── install_neovim.sh       # ✏️  Neovim editor installer
│   └── new_project.sh          # 📂 Project generator
├── personal/                   # 👤 Personal configurations
│   ├── setup_personal_env.sh   # 🏠 Personal environment setup
│   ├── configs/                # ⚙️  Configuration files
│   │   ├── zshrc               # 🐚 ZSH configuration
│   │   ├── p10k.zsh            # 🎨 Powerlevel10k theme config
│   │   └── .ssh/               # 🔐 SSH configurations
│   └── aliases/                # 🔗 Shell aliases
│       ├── system.zsh          # 💻 System commands
│       ├── dev.zsh             # 👨‍💻 Development tools
│       ├── navigation.zsh      # 🧭 Directory navigation
│       ├── remote.zsh          # 🌐 Remote connections
│       ├── python.zsh          # 🐍 Python environment
│       ├── macos.zsh           # 🍎 macOS specific
│       └── linux.zsh           # 🐧 Linux specific
├── TOOLS/                      # 📚 Documentation & guides
│   └── How_tmux.md             # 📖 tmux usage guide
└── utils/                      # 🛠️  Utility functions
    ├── shell_utils.sh          # 🔧 Common shell utilities
    └── demo_utils.sh           # 🎬 Demo and testing tools
```

## 🚀 Quick Start

### Option 1: Complete Setup (Recommended)
```bash
# Clone or download this repository
cd AUTOMATIONS
./setup.sh
# Select option 1 for complete setup
```

### Option 2: Personal Environment Only
```bash
# If you already have ZSH/Oh-My-Zsh installed
cd personal
./setup_personal_env.sh
```

### Option 3: Individual Components
```bash
# Install specific components
./data/install_oh_my_zsh.sh
./data/install_fonts.sh
./data/install_powerlevel10k.sh
./data/install_zsh_plugins.sh
```

## 🎨 Theme & Customization

### Powerlevel10k Color Scheme
Our custom theme uses a carefully selected color palette:
- **Primary Green**: `#74975A` - Commands and success states
- **Purple Accent**: `#BD8BBE` - Highlighting and special elements  
- **Blue Info**: `#649CD3` - Information and paths
- **Orange Warning**: `#F4A261` - Warnings and attention items

### Custom Features
- **Conda Environment Display**: Shows active Python environments
- **Git Integration**: Enhanced git status in prompt
- **Cross-Platform Paths**: Automatic conda path detection
- **Custom Aliases**: 100+ productivity-boosting aliases

## 🔧 Supported Tools & Plugins

### ZSH Plugins
- **zsh-autosuggestions**: Fish-like autosuggestions
- **zsh-syntax-highlighting**: Real-time syntax highlighting
- **you-should-use**: Reminds you to use aliases
- **zsh-completions**: Additional completion definitions

### Development Tools
- **Neovim**: Modern text editor with enhanced features
- **tmux**: Terminal multiplexer for session management
- **Git**: Version control with custom aliases
- **Conda**: Python environment management

## 🌍 Cross-Platform Compatibility

### Supported Operating Systems
- **macOS**: Full support with Homebrew integration
- **Linux**: Ubuntu, Debian, CentOS, Fedora, Arch
- **Synology NAS**: DSM 6.x and 7.x compatible

### OS-Specific Features
- **macOS**: Homebrew package management, Apple-specific aliases
- **Linux**: Package manager detection (apt, yum, pacman)
- **Universal**: Git, SSH, and development tool configurations

## 📖 Usage Examples

### Development Workflow
```bash
# Navigate to projects
repos              # Go to repositories directory
mkcd myproject     # Create and enter directory

# Git shortcuts
gs                 # git status
ga .               # git add all
gc "message"       # git commit with message
gp                 # git push

# Python development
ca myenv           # conda activate environment
pip-list           # show installed packages
pytest-run         # run tests with coverage
```

### System Management
```bash
# System information
sysinfo            # comprehensive system information
ports              # show open ports
processes          # show running processes

# File operations
ll                 # detailed file listing
la                 # show all files including hidden
extract file.zip   # universal archive extraction
```

### Remote Operations
```bash
# SSH connections (configured in .ssh/config)
ssh myserver       # connect to predefined server

# File transfers
backup-to-nas      # sync files to NAS
rsync-project      # sync project files
```

## 🔐 SSH Configuration

The setup includes SSH configuration management:
- Predefined server connections
- Key-based authentication setup
- Secure defaults and best practices
- Cross-platform compatibility

## 🛠️ Troubleshooting

### Common Issues

**1. Oh-My-Zsh installation fails**
```bash
# Check internet connection and try manual installation
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**2. Fonts not displaying correctly**
```bash
# Ensure Nerd Fonts are installed and terminal is configured
./data/install_fonts.sh
# Then restart your terminal
```

**3. Conda not detected**
```bash
# Check conda installation and PATH
which conda
echo $PATH
# Source the configuration again
source ~/.zshrc
```

**4. Plugins not loading**
```bash
# Check plugins array in .zshrc
grep "plugins=" ~/.zshrc
# Reload ZSH configuration
exec zsh
```

### Debug Mode
Enable debug mode for troubleshooting:
```bash
export DEBUG=1
./setup.sh
```

## 🤝 Contributing

### Adding New Features
1. Create modular scripts in `data/` directory
2. Update the master `setup.sh` script
3. Add documentation and examples
4. Test across different operating systems

### File Structure Guidelines
- **data/**: Installation and setup tools
- **personal/**: User-specific configurations
- **utils/**: Shared utility functions
- **Documentation**: Update README for new features

## 📝 License

This project is designed for personal use and development environment automation.

## 🙏 Acknowledgments

- [Oh-My-Zsh](https://ohmyz.sh/) - Amazing ZSH framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Beautiful and fast ZSH theme
- [Nerd Fonts](https://www.nerdfonts.com/) - Iconic font aggregator
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer

---

**Happy coding! 🚀**
