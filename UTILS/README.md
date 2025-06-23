# Shell Utilities Library

A collection of common utility functions for bash/zsh scripts.

## Functions

### print_style()

Prints formatted messages with decorative borders.

```bash
print_style "Your message here" "style"
```

**Parameters:**
- `message`: The text to display
- `style` (optional): Border style - "indented_separator" (default), "box", "section", or "decorative"

### mk_log()

Prints colored messages with optional fancy formatting.

```bash
mk_log "Your message here" "true|false" "green|red|default"
```

**Parameters:**
- `message`: The text to display
- `print_fancy` (optional): Whether to add decorative borders (default: "false")
- `color` (optional): Text color - "default", "green", or "red"

## Usage Example

```bash
#!/bin/bash
# Source the utilities
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
UTILS_PATH="${SCRIPT_DIR}/../UTILS/shell_utils.sh"

if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    echo "Error: Could not find shell utilities at $UTILS_PATH"
    exit 1
fi

# Example usage
mk_log "This is a success message" "true" "green"
mk_log "This is an error message" "true" "red"
mk_log "This is a plain message with fancy border" "true"
mk_log "This is a plain message without border" "false"
```

## Implemented In

This utilities library is used by the following scripts:
- `install_zsh.sh` - ZSH shell installer
- `install_brew.sh` - Homebrew package manager installer
- `install_powerlevel10k.sh` - ZSH Powerlevel10k theme installer
- `install_neovim.sh` - Neovim editor installer
- `install_jetbrains_mono_nerd_font.sh` - Font installer
- `new_project.sh` - Project skeleton creator
- `set_myzsh.sh` - Personal ZSH environment setup
- `install_zsh_plugins.sh` - ZSH plugins installer
