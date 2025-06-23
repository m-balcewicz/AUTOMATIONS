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
brew_path="/opt/homebrew/bin"
brew_opt_path="/opt/homebrew/opt"
nvm_path="$HOME/.nvm"

export NVM_DIR="${nvm_path}"
[ -s "${brew_opt_path}/nvm/nvm.sh" ] && \. "${brew_opt_path}/nvm/nvm.sh"
[ -s "${brew_opt_path}/nvm/etc/bash_completion.d/nvm" ] && \. "${brew_opt_path}/nvm/etc/bash_completion.d/nvm"

# Conda setup
__conda_setup="$('/Users/martin/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/martin/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/martin/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/martin/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# LM Studio CLI
export PATH="$PATH:/Users/martin/.lmstudio/bin"
