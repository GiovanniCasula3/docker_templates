#!/bin/bash

# Windows-compatible script to make shell scripts executable
# Run this with Git Bash or WSL if on Windows

echo "Making scripts executable..."

# Make main setup script executable
chmod +x setup.sh

# Make scripts in scripts directory executable
chmod +x scripts/*.sh

echo "Scripts are now executable!"
echo "You can now run: ./setup.sh"
