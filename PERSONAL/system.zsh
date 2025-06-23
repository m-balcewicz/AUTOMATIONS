# -------------------------------------------------------
# System-related aliases and functions
# -------------------------------------------------------

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
