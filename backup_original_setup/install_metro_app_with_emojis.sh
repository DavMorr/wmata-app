#!/bin/bash

# Metro Train Predictions App - Enhanced Installation Script
# This script sets up the containerized Laravel backend and Vue frontend

set -e  # Exit on any error

echo "🚇 Metro Train Predictions App - Enhanced Setup"
echo "==============================================="
echo ""

# Check if we're in the right directory
if [[ ! -d "laravel-app" ]] || [[ ! -d "vue-app" ]]; then
    echo "❌ Error: This script must be run from the project root directory"
    echo "   Make sure you're in the wmata-app-test directory"
    exit 1
fi

# Check requirements
echo "🔍 Checking system requirements..."

# Check for docker
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    echo "   Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check for docker compose
if ! docker compose version &> /dev/null; then
    echo "❌ Error: Docker Compose is not available"
    echo "   Please ensure Docker Compose is installed and working"
    exit 1
fi

# Check for composer (needed for initial Laravel setup)
if ! command -v composer &> /dev/null; then
    echo "❌ Error: Composer is not installed"
    echo "   Please install Composer: https://getcomposer.org/download/"
    exit 1
fi

echo "✅ All system requirements met!"
echo ""

# Function to validate WMATA API key format (basic validation)
validate_wmata_key() {
    local key="$1"
    if [[ -z "$key" ]]; then
        return 1
    fi
    # WMATA API keys are typically 32-character hex strings
    if [[ ${#key} -ge 32 && "$key" =~ ^[a-fA-F0-9]+$ ]]; then
        return 0
    fi
    return 1
}

# Function to prompt for WMATA API key
get_wmata_api_key() {
    local key=""
    echo "🔑 WMATA API Key Configuration"
    echo "============================="
    echo ""
    echo "This application requires a WMATA API key to fetch Metro data."
    echo "You can get a free API key from: https://developer.wmata.com/"
    echo ""
    
    while true; do
        read -p "Please enter your WMATA API key: " key
        
        if validate_wmata_key "$key"; then
            echo "✅ Valid API key format detected"
            break
        else
            echo "❌ Invalid API key format. WMATA API keys should be 32+ character hex strings."
            echo "   Example format: 1234567890abcdef1234567890abcdef"
            echo ""
            read -p "Would you like to skip this for now? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "⚠️  Skipping API key validation. You can add it later to laravel-app/.env"
                key=""
                break
            fi
        fi
    done
    
    echo "$key"
}

# Laravel Backend Setup
echo "🔧 Setting up Laravel Backend..."
echo "--------------------------------"

cd laravel-app

echo "📝 Setting up environment file..."
if [[ ! -f ".env" ]]; then
    cp .env.example .env
    echo "✅ Created .env file from .env.example"
else
    echo "ℹ️  .env file already exists"
fi

# Check for WMATA API key in .env
echo ""
echo "🔍 Checking WMATA API key configuration..."

current_key=$(grep "^WMATA_API_KEY=" .env 2>/dev/null | cut -d'=' -f2 || echo "")

if [[ -z "$current_key" ]] || ! validate_wmata_key "$current_key"; then
    echo "⚠️  WMATA API key not found or invalid in .env file"
    
    # Check if key exists in .env.example
    example_key=$(grep "^WMATA_API_KEY=" .env.example 2>/dev/null | cut -d'=' -f2 || echo "")
    
    if [[ -n "$example_key" ]] && validate_wmata_key "$example_key"; then
        echo "✅ Found valid API key in .env.example, using it..."
        # Update .env with the key from .env.example
        if grep -q "^WMATA_API_KEY=" .env; then
            sed -i.bak "s/^WMATA_API_KEY=.*/WMATA_API_KEY=$example_key/" .env
        else
            echo "WMATA_API_KEY=$example_key" >> .env
        fi
        echo "✅ WMATA API key configured successfully"
    else
        # Prompt user for API key
        new_key=$(get_wmata_api_key)
        if [[ -n "$new_key" ]]; then
            if grep -q "^WMATA_API_KEY=" .env; then
                sed -i.bak "s/^WMATA_API_KEY=.*/WMATA_API_KEY=$new_key/" .env
            else
                echo "WMATA_API_KEY=$new_key" >> .env
            fi
            echo "✅ WMATA API key saved to .env file"
        fi
    fi
else
    echo "✅ Valid WMATA API key found in .env file"
fi

# Set up Docker environment variables
echo ""
echo "🔧 Setting up Docker environment variables..."
if ! grep -q "WWWUSER=" .env; then
    echo "WWWUSER=$(id -u)" >> .env
fi
if ! grep -q "WWWGROUP=" .env; then
    echo "WWWGROUP=$(id -g)" >> .env
fi

# Generate APP_KEY if not present
if ! grep -q "^APP_KEY=base64:" .env; then
    echo "🔑 Generating Laravel application key..."
    # Generate a random base64 key
    app_key="base64:$(openssl rand -base64 32)"
    if grep -q "^APP_KEY=" .env; then
        sed -i.bak "s/^APP_KEY=.*/APP_KEY=$app_key/" .env
    else
        echo "APP_KEY=$app_key" >> .env
    fi
    echo "✅ Laravel application key generated"
fi

echo "📦 Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader

echo "✅ Laravel backend setup complete!"
echo ""

# Vue Frontend Setup
echo "🔧 Setting up Vue Frontend..."
echo "-----------------------------"

cd ../vue-app

echo "📝 Updating environment configuration..."
# Ensure the Vue .env file has the correct configuration
cat > .env << EOF
# Laravel API Base URL 
# Note: This should remain localhost because API calls are made by the browser, not the container
VITE_API_BASE_URL=http://localhost/api
VITE_API_URL=http://localhost/api

# Development settings
VITE_APP_NAME="Metro Transit Predictor"
VITE_PREDICTIONS_REFRESH_INTERVAL=30

# Development mode settings
VITE_APP_DEBUG=true
VITE_APP_ENV=development
EOF

echo "✅ Vue frontend configuration updated!"
echo ""

# Go back to project root
cd ..

# Create the necessary Docker files
echo "🐳 Setting up Docker configuration..."

# Laravel Dockerfile will be created by the artifacts above
# Vue Dockerfile will be created by the artifacts above
# Root docker-compose.yml will be created by the artifacts above

echo "✅ Docker configuration ready!"
echo ""

# Build and start containers
echo "🚀 Building and starting containers..."
echo "======================================"

# Build the containers
echo "📦 Building Docker images..."
docker compose build

echo "🐳 Starting services..."
docker compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if Laravel is responding
echo "🔍 Checking Laravel backend health..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -s -f http://localhost/api/test &>/dev/null; then
        echo "✅ Laravel backend is responding!"
        break
    else
        echo "   Attempt $attempt/$max_attempts: Waiting for Laravel backend..."
        sleep 2
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "⚠️  Laravel backend took longer than expected to start"
    echo "   You can check the logs with: docker compose logs laravel-backend"
fi

echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "✅ Laravel backend: http://localhost"
echo "✅ Vue frontend: http://localhost:5173"
echo "✅ MySQL database: localhost:3306"
echo "✅ Redis cache: localhost:6379"
echo ""
echo "To manage the application:"
echo "• Start: metro up (or docker compose up -d)"
echo "• Stop: metro down (or docker compose down)"
echo "• View logs: docker compose logs [service-name]"
echo "• Check status: docker compose ps"
echo ""
echo "🔧 Development commands:"
echo "• Laravel shell: docker compose exec laravel-backend bash"
echo "• Vue shell: docker compose exec vue-frontend sh"
echo "• Run migrations: docker compose exec laravel-backend php artisan migrate"
echo "• Clear cache: docker compose exec laravel-backend php artisan cache:clear"
echo ""

# Check WMATA API key status
current_key=$(grep "^WMATA_API_KEY=" laravel-app/.env 2>/dev/null | cut -d'=' -f2 || echo "")
if [[ -z "$current_key" ]]; then
    echo "⚠️  Note: WMATA API key not configured. Add it to laravel-app/.env to enable full functionality."
else
    echo "✅ WMATA API key configured and ready!"
fi

echo ""
echo "Happy coding! 🚇"