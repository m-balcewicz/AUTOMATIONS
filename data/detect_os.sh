#!/bin/bash
# ---------------------------------------
# Script: detect_os.sh
# Author: Martin Balcewicz
# Date: October 2025
# Description: Detects the operating system
# ---------------------------------------

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# If script is executed directly, output the OS
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os
fi
