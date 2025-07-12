#!/bin/bash

# Metro Command Setup Script
# This script creates a 'metro' command with subcommands

echo "🚇 Metro Command Setup"
echo "====================="
echo ""
echo "This script will create a 'metro' command with the following subcommands:"
echo "• metro install  - Run install_metro_app.sh"
echo "• metro up       - Run start_metro_app.sh"
echo "• metro down     - Run stop_metro_app.sh"
echo ""

# Detect current shell
current_shell=$(basename "$SHELL")
echo "🔍 Detected shell: $current_shell"
echo ""

# Present options
echo "📝 Select your shell configuration file:"
echo ""
echo "1) Bash (~/.bashrc)"
echo "2) Bash (~/.bash_profile)" 
echo "3) Zsh (~/.zshrc)"
echo "4) Fish (~/.config/fish/config.fish)"
echo "5) Auto-detect based on current shell"
echo "6) Custom path"
echo "7) Just show me the function (I'll add it manually)"
echo ""

read -p "Enter your choice (1-7): " choice

# Define the metro function for Bash/Zsh
read -r -d '' METRO_FUNCTION << 'EOF'
# Metro Train Predictions App command
function metro() {
    # Find the project root by looking for the Metro app scripts
    local dir="$PWD"
    local project_root=""
    
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/install_metro_app.sh" ]] && [[ -f "$dir/start_metro_app.sh" ]]; then
            project_root="$dir"
            break
        fi
        dir="$(dirname "$dir")"
    done
    
    if [[ -z "$project_root" ]]; then
        echo "❌ Metro app scripts not found. Make sure you're in the project directory or subdirectory."
        return 1
    fi
    
    case "$1" in
        "install")
            echo "🚇 Running Metro App Installation..."
            bash "$project_root/install_metro_app.sh"
            ;;
        "up")
            echo "🚇 Starting Metro App..."
            bash "$project_root/start_metro_app.sh"
            ;;
        "down")
            echo "🚇 Stopping Metro App..."
            if [[ -f "$project_root/stop_metro_app.sh" ]]; then
                bash "$project_root/stop_metro_app.sh"
            else
                echo "🛑 Stopping Laravel backend..."
                cd "$project_root/laravel-app" && ./vendor/bin/sail down
                echo "✅ Laravel backend stopped"
                echo "💡 Vue frontend stops when you press Ctrl+C in its terminal"
            fi
            ;;
        "status")
            echo "🚇 Metro App Status:"
            echo "==================="
            # Use subshell to avoid changing the current directory
            (
                cd "$project_root/laravel-app"
                if ./vendor/bin/sail ps 2>/dev/null | grep -q "Up"; then
                    echo "✅ Laravel backend: Running"
                else
                    echo "❌ Laravel backend: Stopped"
                fi
            )
            
            # More accurate Vue frontend detection
            # Check if we can actually get the Vite dev server response
            if curl -s --connect-timeout 2 http://localhost:5173 2>/dev/null | grep -q "<!DOCTYPE html>\|<html"; then
                echo "✅ Vue frontend: Running (port 5173)"
            elif pgrep -f "npm.*run.*dev\|vite.*dev\|node.*vite" >/dev/null 2>&1; then
                echo "⚠️  Vue frontend: Process detected but not responding properly"
            elif lsof -Pi :5173 -sTCP:LISTEN | grep -v "com.docke" | grep -q ":5173"; then
                echo "⚠️  Vue frontend: Port 5173 occupied by non-Docker process"
            else
                echo "❌ Vue frontend: Stopped"
            fi
            ;;
        "help"|"")
            echo "🚇 Metro Train Predictions App Commands"
            echo "======================================="
            echo ""
            echo "Usage: metro <command>"
            echo ""
            echo "Commands:"
            echo "  install    Install and set up the Metro app"
            echo "  up         Start both Laravel backend and Vue frontend"
            echo "  down       Stop the Metro app services"
            echo "  status     Check if services are running"
            echo "  help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  metro install    # First-time setup"
            echo "  metro up         # Start development servers"
            echo "  metro down       # Stop all services"
            echo "  metro status     # Check what's running"
            ;;
        *)
            echo "❌ Unknown command: $1"
            echo "💡 Run 'metro help' to see available commands"
            return 1
            ;;
    esac
}
EOF

# Fish shell version
read -r -d '' FISH_FUNCTION << 'EOF'
# Metro Train Predictions App command for Fish shell
function metro
    # Find the project root by looking for the Metro app scripts
    set dir $PWD
    set project_root ""
    
    while test "$dir" != "/"
        if test -f "$dir/install_metro_app.sh" -a -f "$dir/start_metro_app.sh"
            set project_root "$dir"
            break
        end
        set dir (dirname "$dir")
    end
    
    if test -z "$project_root"
        echo "❌ Metro app scripts not found. Make sure you're in the project directory or subdirectory."
        return 1
    end
    
    switch "$argv[1]"
        case "install"
            echo "🚇 Running Metro App Installation..."
            bash "$project_root/install_metro_app.sh"
        case "up"
            echo "🚇 Starting Metro App..."
            bash "$project_root/start_metro_app.sh"
        case "down"
            echo "🚇 Stopping Metro App..."
            if test -f "$project_root/stop_metro_app.sh"
                bash "$project_root/stop_metro_app.sh"
            else
                echo "🛑 Stopping Laravel backend..."
                cd "$project_root/laravel-app" && ./vendor/bin/sail down
                echo "✅ Laravel backend stopped"
                echo "💡 Vue frontend stops when you press Ctrl+C in its terminal"
            end
        case "status"
            echo "🚇 Metro App Status:"
            echo "==================="
            cd "$project_root/laravel-app"
            if ./vendor/bin/sail ps 2>/dev/null | grep -q "Up"
                echo "✅ Laravel backend: Running"
            else
                echo "❌ Laravel backend: Stopped"
            end
            
            # More accurate Vue frontend detection for Fish
            if curl -s --connect-timeout 2 http://localhost:5173 >/dev/null 2>&1
                echo "✅ Vue frontend: Running (port 5173)"
            else if pgrep -f "vite.*5173" >/dev/null 2>&1
                echo "⚠️  Vue frontend: Process running but not responding"
            else if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null 2>&1
                echo "⚠️  Vue frontend: Port occupied by unknown process"
            else
                echo "❌ Vue frontend: Stopped"
            end
        case "help" ""
            echo "🚇 Metro Train Predictions App Commands"
            echo "======================================="
            echo ""
            echo "Usage: metro <command>"
            echo ""
            echo "Commands:"
            echo "  install    Install and set up the Metro app"
            echo "  up         Start both Laravel backend and Vue frontend"
            echo "  down       Stop the Metro app services"
            echo "  status     Check if services are running"
            echo "  help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  metro install    # First-time setup"
            echo "  metro up         # Start development servers"
            echo "  metro down       # Stop all services"
            echo "  metro status     # Check what's running"
        case "*"
            echo "❌ Unknown command: $argv[1]"
            echo "💡 Run 'metro help' to see available commands"
            return 1
    end
end
EOF

case $choice in
    1)
        config_file="$HOME/.bashrc"
        function_to_add="$METRO_FUNCTION"
        ;;
    2)
        config_file="$HOME/.bash_profile"
        function_to_add="$METRO_FUNCTION"
        ;;
    3)
        config_file="$HOME/.zshrc"
        function_to_add="$METRO_FUNCTION"
        ;;
    4)
        config_file="$HOME/.config/fish/config.fish"
        function_to_add="$FISH_FUNCTION"
        mkdir -p "$(dirname "$config_file")"
        ;;
    5)
        # Auto-detect
        case $current_shell in
            "zsh")
                config_file="$HOME/.zshrc"
                function_to_add="$METRO_FUNCTION"
                ;;
            "bash")
                if [[ -f "$HOME/.bashrc" ]]; then
                    config_file="$HOME/.bashrc"
                else
                    config_file="$HOME/.bash_profile"
                fi
                function_to_add="$METRO_FUNCTION"
                ;;
            "fish")
                config_file="$HOME/.config/fish/config.fish"
                function_to_add="$FISH_FUNCTION"
                mkdir -p "$(dirname "$config_file")"
                ;;
            *)
                echo "❌ Unknown shell: $current_shell"
                echo "   Please choose a specific option or use option 7"
                exit 1
                ;;
        esac
        ;;
    6)
        read -p "Enter the full path to your shell config file: " config_file
        if [[ "$config_file" == *"fish"* ]]; then
            function_to_add="$FISH_FUNCTION"
        else
            function_to_add="$METRO_FUNCTION"
        fi
        ;;
    7)
        echo ""
        echo "🔧 Metro Function Code:"
        echo "======================"
        echo ""
        echo "For Bash/Zsh, add this to your shell config file:"
        echo ""
        echo "$METRO_FUNCTION"
        echo ""
        echo "For Fish shell, add this to ~/.config/fish/config.fish:"
        echo ""
        echo "$FISH_FUNCTION"
        echo ""
        echo "After adding, reload your shell with: source ~/.zshrc (or your config file)"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

# Check if config file exists
if [[ ! -f "$config_file" ]]; then
    echo "📁 Creating config file: $config_file"
    touch "$config_file"
fi

# Check if function already exists
if grep -q "function metro" "$config_file"; then
    echo "⚠️  A metro function already exists in $config_file"
    read -p "   Do you want to replace it? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Replacing existing function..."
        # Remove existing function (basic removal)
        sed -i.bak '/# Metro Train Predictions App command/,/^}/d' "$config_file"
    else
        echo "❌ Aborted - existing function kept"
        exit 0
    fi
fi

# Add the function
echo "" >> "$config_file"
echo "# Metro Train Predictions App command (added by setup script)" >> "$config_file"
echo "$function_to_add" >> "$config_file"

echo "✅ Metro command added to $config_file"
echo ""
echo "🔄 To use the new command, either:"
echo "   • Open a new terminal, or"
echo "   • Run: source $config_file"
echo ""
echo "🎉 You can now use 'metro' commands from anywhere in your project!"
echo ""
echo "Examples:"
echo "  metro install    # Install and set up the app"
echo "  metro up         # Start development servers"
echo "  metro down       # Stop all services"
echo "  metro status     # Check service status"
echo "  metro help       # Show help"
