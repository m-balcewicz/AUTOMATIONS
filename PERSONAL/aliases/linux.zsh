#!/bin/zsh
# ---------------------------------------
# Linux-specific aliases and configurations
# Author: Martin Balcewicz  
# Date: October 2025
# ---------------------------------------

# Check if we're on Linux before applying these settings
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    
    # Package management aliases (works for both apt and yum/dnf systems)
    if command -v apt &> /dev/null; then
        alias update='sudo apt update && sudo apt upgrade'
        alias install='sudo apt install'
        alias search='apt search'
        alias remove='sudo apt remove'
        alias autoremove='sudo apt autoremove'
    elif command -v yum &> /dev/null; then
        alias update='sudo yum update'
        alias install='sudo yum install'
        alias search='yum search'
        alias remove='sudo yum remove'
    elif command -v dnf &> /dev/null; then
        alias update='sudo dnf update'
        alias install='sudo dnf install'
        alias search='dnf search'
        alias remove='sudo dnf remove'
    fi
    
    # System monitoring aliases
    alias ports='netstat -tulanp'
    alias meminfo='free -h'
    alias psmem='ps auxf | sort -nr -k 4'
    alias pscpu='ps auxf | sort -nr -k 3'
    alias diskinfo='df -h'
    alias diskusage='du -sh * | sort -hr'
    
    # Service management (systemd)
    if command -v systemctl &> /dev/null; then
        alias services='systemctl list-units --type=service'
        alias start='sudo systemctl start'
        alias stop='sudo systemctl stop'
        alias restart='sudo systemctl restart'
        alias status='systemctl status'
        alias enable='sudo systemctl enable'
        alias disable='sudo systemctl disable'
    fi
    
    # Network utilities
    alias myip='curl -s http://whatismyip.akamai.com/'
    alias localip="ip route get 1 | awk '{print \$NF;exit}'"
    alias netinfo='ip addr show'
    
    # File operations (Linux-specific ls options)
    alias ls='ls --color=auto'
    alias ll='ls -alh --color=auto'
    alias la='ls -lah --color=auto'
    alias l='ls -lh --color=auto'
    
    # Directory operations
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    
    # Grep with color
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    
    # Process management
    alias psg='ps aux | grep'
    alias topcpu='top -o %CPU'
    alias topmem='top -o %MEM'
    
    # Archive utilities
    alias tarx='tar -xvf'
    alias tarc='tar -cvf'
    alias tarz='tar -czvf'
    alias untar='tar -xvf'
    
    # Quick editors
    alias vim='vim'
    alias vi='vim'
    if command -v nano &> /dev/null; then
        alias edit='nano'
    elif command -v vim &> /dev/null; then
        alias edit='vim'
    fi
    
    # System information
    alias sysinfo='uname -a && cat /etc/os-release'
    alias cpuinfo='cat /proc/cpuinfo'
    alias kernel='uname -r'
    
    # Log viewing
    alias logs='sudo journalctl -f'
    alias syslog='sudo tail -f /var/log/syslog'
    alias messages='sudo tail -f /var/log/messages'
    
    # Quick navigation shortcuts
    alias home='cd ~'
    alias root='cd /'
    alias dtop='cd ~/Desktop'
    alias docs='cd ~/Documents'
    alias downloads='cd ~/Downloads'
    
    # Git shortcuts (if git is installed)
    if command -v git &> /dev/null; then
        alias gs='git status'
        alias ga='git add'
        alias gc='git commit'
        alias gp='git push'
        alias gl='git log --oneline'
        alias gd='git diff'
        alias gb='git branch'
        alias gco='git checkout'
        alias gcl='git clone'
    fi
    
    # Python shortcuts (if python is installed)
    if command -v python3 &> /dev/null; then
        alias python='python3'
        alias py='python3'
        alias pip='pip3'
    fi
    
    # Node.js shortcuts (if node is installed)
    if command -v node &> /dev/null; then
        alias nodemodules='cd node_modules'
        alias ni='npm install'
        alias ns='npm start'
        alias nt='npm test'
        alias nr='npm run'
    fi
    
    # Docker shortcuts (if docker is installed)
    if command -v docker &> /dev/null; then
        alias dps='docker ps'
        alias dpsa='docker ps -a'
        alias di='docker images'
        alias drm='docker rm'
        alias drmi='docker rmi'
        alias dstop='docker stop'
        alias dstart='docker start'
        alias drestart='docker restart'
        alias dlogs='docker logs'
        alias dexec='docker exec -it'
        alias dcompose='docker-compose'
    fi
    
    echo "✓ Linux-specific aliases loaded"
else
    echo "ℹ Linux aliases skipped (not on Linux system)"
fi
