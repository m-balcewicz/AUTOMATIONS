# ---------------------------------------
# Filename: dev.zsh
# Author: Martin Balcewicz
# Date: June 2025
# Description: Development-related aliases and functions.
# ---------------------------------------

# -------------------------------------------------------
# Development-related aliases and functions
# -------------------------------------------------------

# Git shortcuts
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"

# Node Version Manager setup
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# LM Studio CLI
export PATH="$PATH:/Users/martin/.lmstudio/bin"
