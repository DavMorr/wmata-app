#!/bin/bash
# Make all metro scripts executable
echo "Making Metro scripts executable..."
chmod +x metro-install.sh
chmod +x metro-start.sh  
chmod +x metro-stop.sh
chmod +x metro-reset.sh
chmod +x metro-destroy.sh
chmod +x metro-setup-command.sh
echo "All Metro scripts are now executable"
echo ""
echo "Available commands:"
echo "  ./metro-install.sh        - First-time installation"
echo "  ./metro-start.sh          - Start development environment"
echo "  ./metro-stop.sh           - Stop services"
echo "  ./metro-reset.sh          - Quick reset (development)"
echo "  ./metro-destroy.sh        - Complete teardown (distribution)"
echo "  ./metro-setup-command.sh  - Set up unified 'metro' command system"
echo ""
echo "Recommended next step:"
echo "  ./metro-setup-command.sh  # Creates space-delimited metro commands"