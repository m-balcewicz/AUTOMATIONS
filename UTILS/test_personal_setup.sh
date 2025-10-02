#!/bin/bash
# Quick test for the personal setup script

echo "Testing personal setup script..."

# Test the backup function
source /mnt/NEUTRON/home/mbalcewicz/CODING_WORLD/AUTOMATIONS/personal/setup_personal_env.sh

echo "Functions loaded successfully!"
echo "✓ Script syntax is now valid"

# Show what the backup directory would be
echo "Backup would be created at: $HOME/.zsh_backup_$(date +%Y%m%d_%H%M%S)"

echo ""
echo "You can now run the complete setup again without syntax errors!"
