# ---------------------------------------
# Filename: navigation.zsh
# Author: Martin Balcewicz
# Date: June 2025
# Description: Directory navigation aliases.
# ---------------------------------------

# Terminal UI with colorized ls
if command -v lsd &> /dev/null; then
    # Use lsd if available (modern ls replacement)
    alias lsd='lsd --icon=always'
    alias ls='lsd --color always --group-dirs first'
    alias ll='lsd -l --color always --group-dirs first'
    alias la='lsd -la --color always --group-dirs first'
else
    # Fallback to standard ls with appropriate options for each OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS ls
        alias ls='ls -G'
        alias ll='ls -alh -G'
        alias la='ls -lah -G'
    else
        # Linux ls
        alias ls='ls --color=auto'
        alias ll='ls -alh --color=auto'
        alias la='ls -lah --color=auto'
    fi
fi


# Basic navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Project navigation
alias goPYTHON="cd ~/MYDATA/CODING_WORLD/PYTHON_WORLD"
alias goGITHUB="cd ~/MYDATA/CODING_WORLD/GITHUB_WORLD"
alias goSCIENCE="cd ~/MYDATA/SCIENCE_WORLD" 
alias goPROJECTS="cd ~/MYDATA/PROJECT_WORLD/"
alias goRottenmeier="cd ~/MYDATA/CODING_WORLD/GITHUB_WORLD/Miss_Rottenmeier"
