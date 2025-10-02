# ---------------------------------------
# Filename: macos.zsh
# Author: Martin Balcewicz
# Date: June 2025
# Description: macOS-specific aliases and configurations.
# ---------------------------------------

# Language and locale settings
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# Homebrew configuration
eval "$(/opt/homebrew/bin/brew shellenv)"

# General /usr/local variables, also needed by brew
export PATH=$PATH:/usr/local/bin
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib
export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:/usr/local/lib
