#!/bin/bash

# Metro Train Predictions App - Shell Aliases Setup
# Add convenient shortcuts for Docker commands

echo "🔧 Setting up Metro command aliases..."
echo ""

# Detect shell type
SHELL_RC=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="Zsh"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="Bash"
else
    echo "⚠️  Unknown shell type. Please add aliases manually to your shell configuration."
    echo "   Current shell: $SHELL"
    exit 1
fi

echo "📝 Adding aliases to $SHELL_NAME configuration ($SHELL_RC)..."

# Add aliases to shell configuration
cat >> "$SHELL_RC" << 'EOF'

# Metro Train Predictions App - Docker Command Aliases
alias metro-artisan='docker compose exec laravel-backend php artisan'
alias metro-tinker='docker compose exec laravel-backend php artisan tinker'
alias metro-sync='docker compose exec laravel-backend php artisan metro:sync'
alias metro-logs='docker compose logs laravel-backend'
alias metro-vue-logs='docker compose logs vue-frontend'
alias metro-mysql='docker compose exec mysql mysql -u root -ppassword'
alias metro-redis='docker compose exec redis redis-cli'
alias metro-ps='docker compose ps'

EOF

echo "✅ Aliases added successfully!"
echo ""
echo "🔄 To use the aliases immediately, run:"
echo "   source $SHELL_RC"
echo ""
echo "📋 Available aliases:"
echo "   metro-artisan    - Run Laravel artisan commands"
echo "   metro-tinker     - Open Laravel tinker REPL"
echo "   metro-sync       - Sync Metro data from WMATA API"
echo "   metro-logs       - View Laravel container logs"
echo "   metro-vue-logs   - View Vue container logs"
echo "   metro-mysql      - Access MySQL database"
echo "   metro-redis      - Access Redis CLI"
echo "   metro-ps         - Show container status"
echo ""
echo "📖 Examples:"
echo "   metro-artisan migrate"
echo "   metro-sync"
echo "   metro-tinker"
echo ""