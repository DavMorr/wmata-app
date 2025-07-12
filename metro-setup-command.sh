#!/bin/bash

# Metro Train Predictions App - Command System Setup
# Creates a unified 'metro' command with subcommands and directory-aware functionality

echo "Metro Train Predictions App - Command System Setup"
echo "================================================="
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
    echo "WARNING: Unknown shell type. Please add function manually to your shell configuration."
    echo "         Current shell: $SHELL"
    exit 1
fi

echo "Adding metro command function to $SHELL_NAME configuration ($SHELL_RC)..."

# Create the metro function
cat >> "$SHELL_RC" << 'EOF'

# Metro Train Predictions App - Unified Command System
# Usage: metro <command> [args...]
metro() {
    # Check if we're in a metro project directory
    if [[ ! -f "docker-compose.yml" ]] || [[ ! -d "laravel-app" ]] || [[ ! -d "vue-app" ]]; then
        echo "ERROR: 'metro' command must be run from a Metro Train Predictions project directory"
        echo "       Looking for: docker-compose.yml, laravel-app/, vue-app/"
        echo "       Current directory: $(pwd)"
        return 1
    fi
    
    case $1 in
        # Management commands
        install|setup)
            echo "Running Metro installation..."
            ./metro-install.sh
            ;;
        start)
            echo "Starting Metro services..."
            ./metro-start.sh
            ;;
        stop)
            echo "Stopping Metro services..."
            ./metro-stop.sh
            ;;
        reset)
            echo "Resetting Metro application..."
            ./metro-reset.sh
            ;;
        destroy)
            echo "Destroying Metro application..."
            ./metro-destroy.sh
            ;;
            
        # Laravel commands
        sync)
            echo "Syncing Metro data from WMATA API..."
            docker compose exec laravel-backend php artisan metro:sync
            ;;
        artisan)
            shift  # Remove 'artisan' from arguments
            if [[ $# -eq 0 ]]; then
                echo "Usage: metro artisan <command> [args...]"
                echo "Examples:"
                echo "  metro artisan migrate"
                echo "  metro artisan cache:clear"
                echo "  metro artisan route:list"
                return 1
            fi
            docker compose exec laravel-backend php artisan "$@"
            ;;
        tinker)
            echo "Opening Laravel Tinker REPL..."
            docker compose exec laravel-backend php artisan tinker
            ;;
            
        # Docker commands
        logs)
            if [[ -n "$2" ]]; then
                docker compose logs "$2"
            else
                docker compose logs laravel-backend
            fi
            ;;
        ps|status)
            echo "Metro container status:"
            docker compose ps
            ;;
        build)
            echo "Rebuilding Metro containers..."
            docker compose build
            ;;
            
        # Database commands
        mysql)
            echo "Connecting to Metro database..."
            docker compose exec mysql mysql -u root -ppassword laravel
            ;;
        redis)
            echo "Connecting to Metro Redis..."
            docker compose exec redis redis-cli
            ;;
            
        # Help and info
        help|--help|-h)
            echo "Metro Train Predictions App - Command Reference"
            echo "=============================================="
            echo ""
            echo "Management Commands:"
            echo "  metro install|setup    First-time installation"
            echo "  metro start            Start development environment"
            echo "  metro stop             Stop all services"
            echo "  metro reset            Quick reset (clear data, keep images)"
            echo "  metro destroy          Complete teardown (for distribution)"
            echo ""
            echo "Laravel Commands:"
            echo "  metro sync             Sync Metro data from WMATA API"
            echo "  metro artisan <cmd>    Run Laravel artisan commands"
            echo "  metro tinker           Open Laravel Tinker REPL"
            echo ""
            echo "Docker Commands:"
            echo "  metro logs [service]   View container logs (default: laravel-backend)"
            echo "  metro ps               Show container status"
            echo "  metro build            Rebuild containers"
            echo ""
            echo "Database Commands:"
            echo "  metro mysql            Connect to MySQL database"
            echo "  metro redis            Connect to Redis CLI"
            echo ""
            echo "Examples:"
            echo "  metro setup"
            echo "  metro start"
            echo "  metro artisan migrate"
            echo "  metro artisan route:list"
            echo "  metro logs vue-frontend"
            echo "  metro sync"
            echo ""
            ;;
        version|--version)
            echo "Metro Train Predictions App"
            echo "Unified command system for Laravel + Vue development"
            ;;
        *)
            if [[ -z "$1" ]]; then
                echo "Metro Train Predictions App"
                echo "Usage: metro <command> [args...]"
                echo "Run 'metro help' for available commands"
            else
                echo "Unknown command: $1"
                echo "Run 'metro help' for available commands"
            fi
            return 1
            ;;
    esac
}

# Tab completion for metro command (bash)
if [[ -n "$BASH_VERSION" ]]; then
    _metro_completions() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local commands="install setup start stop reset destroy sync artisan tinker logs ps build mysql redis help version"
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    }
    complete -F _metro_completions metro
fi

EOF

echo "Metro command system installed successfully!"
echo ""
echo "To use the metro command immediately, run:"
echo "  source $SHELL_RC"
echo ""
echo "Available commands (run from project directory):"
echo "  metro help             Show all available commands"
echo "  metro setup            First-time installation"
echo "  metro start            Start development environment"
echo "  metro stop             Stop all services"
echo "  metro reset            Quick reset (clear data, keep images)"
echo "  metro destroy          Complete teardown (for distribution)"
echo "  metro sync             Sync Metro data from WMATA API"
echo "  metro artisan <cmd>    Run any Laravel artisan command"
echo "  metro tinker           Open Laravel Tinker REPL"
echo "  metro logs [service]   View container logs (default: laravel-backend)"
echo "  metro ps               Show container status"
echo "  metro mysql            Connect to MySQL database"
echo "  metro redis            Connect to Redis CLI"
echo ""
echo "Features:"
echo "  - Directory-aware: Only works in Metro project directories"
echo "  - Tab completion: Press TAB to see available commands"
echo "  - Unified interface: All Metro commands through one entry point"
echo ""
echo "Examples:"
echo "  metro setup                    # First-time installation"
echo "  metro start                    # Start development environment"
echo "  metro artisan migrate          # Run database migrations"
echo "  metro artisan route:list       # List all routes"
echo "  metro artisan make:model User  # Create new model"
echo "  metro logs vue-frontend        # View Vue container logs"
echo "  metro tinker                   # Open Laravel REPL"
echo "  metro sync                     # Manual Metro data sync"
echo ""