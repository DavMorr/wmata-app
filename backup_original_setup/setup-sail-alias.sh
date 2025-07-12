#!/bin/bash

# Laravel Sail Alias Setup Script
# This script adds the sail function to your shell configuration

echo "🛠️  Laravel Sail Alias Setup"
echo "============================"
echo ""
echo "This script will add a 'sail' function to your shell configuration"
echo "that allows you to run sail commands from any subdirectory in your Laravel project."
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

# Define the sail function
read -r -d '' SAIL_FUNCTION << 'EOF'
# Laravel Sail function - allows running sail from any project subdirectory
function sail() {
    # Find the project root by looking for composer.json
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/composer.json" ]]; then
            if [[ -f "$dir/sail" ]]; then
                bash "$dir/sail" "$@"
            elif [[ -f "$dir/vendor/bin/sail" ]]; then
                bash "$dir/vendor/bin/sail" "$@"
            else
                echo "❌ Sail not found in project root"
                return 1
            fi
            return
        fi
        dir="$(dirname "$dir")"
    done
    echo "❌ Not in a Laravel project (no composer.json found)"
    return 1
}
EOF

# Fish shell version (different syntax)
read -r -d '' FISH_FUNCTION << 'EOF'
# Laravel Sail function for Fish shell
function sail
    # Find the project root by looking for composer.json
    set dir $PWD
    while test "$dir" != "/"
        if test -f "$dir/composer.json"
            if test -f "$dir/sail"
                bash "$dir/sail" $argv
            else if test -f "$dir/vendor/bin/sail"
                bash "$dir/vendor/bin/sail" $argv
            else
                echo "❌ Sail not found in project root"
                return 1
            end
            return
        end
        set dir (dirname "$dir")
    end
    echo "❌ Not in a Laravel project (no composer.json found)"
    return 1
end
EOF

case $choice in
    1)
        config_file="$HOME/.bashrc"
        function_to_add="$SAIL_FUNCTION"
        ;;
    2)
        config_file="$HOME/.bash_profile"
        function_to_add="$SAIL_FUNCTION"
        ;;
    3)
        config_file="$HOME/.zshrc"
        function_to_add="$SAIL_FUNCTION"
        ;;
    4)
        config_file="$HOME/.config/fish/config.fish"
        function_to_add="$FISH_FUNCTION"
        # Create fish config directory if it doesn't exist
        mkdir -p "$(dirname "$config_file")"
        ;;
    5)
        # Auto-detect
        case $current_shell in
            "zsh")
                config_file="$HOME/.zshrc"
                function_to_add="$SAIL_FUNCTION"
                ;;
            "bash")
                if [[ -f "$HOME/.bashrc" ]]; then
                    config_file="$HOME/.bashrc"
                else
                    config_file="$HOME/.bash_profile"
                fi
                function_to_add="$SAIL_FUNCTION"
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
            function_to_add="$SAIL_FUNCTION"
        fi
        ;;
    7)
        echo ""
        echo "🔧 Sail Function Code:"
        echo "====================="
        echo ""
        echo "For Bash/Zsh, add this to your shell config file:"
        echo ""
        echo "$SAIL_FUNCTION"
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
if grep -q "function sail" "$config_file"; then
    echo "⚠️  A sail function already exists in $config_file"
    read -p "   Do you want to replace it? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove existing function (basic removal - might need manual cleanup)
        echo "🔄 Replacing existing function..."
        # This is a simple approach - for complex cases, manual editing might be needed
        grep -v "function sail" "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
    else
        echo "❌ Aborted - existing function kept"
        exit 0
    fi
fi

# Add the function
echo "" >> "$config_file"
echo "# Laravel Sail function (added by setup script)" >> "$config_file"
echo "$function_to_add" >> "$config_file"

echo "✅ Sail function added to $config_file"
echo ""
echo "🔄 To use the new function, either:"
echo "   • Open a new terminal, or"
echo "   • Run: source $config_file"
echo ""
echo "🎉 You can now use 'sail' from any directory in your Laravel projects!"
echo ""
echo "Examples:"
echo "  sail up -d"
echo "  sail artisan migrate"
echo "  sail composer install"