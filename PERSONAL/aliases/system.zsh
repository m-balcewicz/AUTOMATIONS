# ---------------------------------------
# Filename: system.zsh
# Author: Martin Balcewicz
# Date: June 2025
# Description: System-related aliases and functions.
# ---------------------------------------

# Directory colors - set to orange (~#EE8133)
# LSCOLORS: used by macOS native ls (first pair = directory)
export LSCOLORS="Dxfxcxdxbxegedabagacad"
# LS_COLORS: used by GNU ls (Linux) - replace any existing di= value
export LS_COLORS="${LS_COLORS//di=*([^:]):/}di=38;5;214:"

# Shell editing/reloading
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
alias zshreload="source ~/.zshrc"

# Edit vim config
alias edit_vim="$EDITOR ~/.vimrc"

# System maintenance functions
update_mac() {
    echo "#---------- Update macOS ----------#"
    echo "####################################"
    softwareupdate --all --install --force
}

update_appstore() {
    echo "#---------- Update App Store ----------#"
    echo "########################################"
    mas upgrade
}

update_brew() {
    echo "#---------- Update Homebrew ----------#"
    echo "#######################################"
    brew doctor
    echo ""
    echo ""
    brew update
    echo ""
    echo ""
    brew upgrade
}

update_matlab() {
    echo "#---------- Update Matlab ----------#"
    echo "#####################################"
    sudo /Applications/MATLAB_R2022a.app/bin/maci64/update_installer
}

update_office() {
    echo "#---------- Update Office ----------#"
    echo "#####################################"
    /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate -l
    sudo /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install
}

# System information display
alias sysinfo="system_profiler SPHardwareDataType SPSoftwareDataType"
alias diskspace="df -h | grep -v tmpfs"
alias meminfo="top -l 1 | grep PhysMem"
