#!/bin/bash

# Metro Train Predictions App - Startup Script
# This script starts the Laravel backend and Vue frontend for a pre-installed site

set -e  # Exit on any error

echo "🚇 Metro Train Predictions App - Starting Services"
echo "================================================="
echo ""

# Check if we're in the right directory
if [[ ! -d "laravel-app" ]] || [[ ! -d "vue-app" ]]; then
    echo "❌ Error: This script must be run from the project root directory"
    echo "   Make sure you're in the 'wmata-app' directory"
    exit 1
fi

# Check if Laravel is set up
if [[ ! -f "laravel-app/.env" ]]; then
    echo "❌ Error: Laravel app not set up yet"
    echo "   Please run './install.sh' first"
    exit 1
fi

# Check if Vue dependencies are installed
if [[ ! -d "vue-app/node_modules" ]]; then
    echo "❌ Error: Vue app dependencies not installed"
    echo "   Please run './install.sh' first"
    exit 1
fi

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Check for port conflicts
echo "🔍 Checking for port conflicts..."

if check_port 80; then
    echo "⚠️  Warning: Port 80 is already in use"
    echo "   Please stop other services using port 80"
    read -p "   Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if check_port 5173; then
    echo "⚠️  Warning: Port 5173 is already in use"
    echo "   Please stop other services using port 5173"
    read -p "   Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Start Laravel Backend
echo "🚀 Starting Laravel Backend..."
echo "-----------------------------"

cd laravel-app

# Check if Docker containers are already running
if docker compose ps | grep -q "Up"; then
    echo "ℹ️  Docker containers already running"
else
    echo "🐳 Starting Docker containers..."
    ./vendor/bin/sail up -d
fi

# Wait a moment for containers to be ready
sleep 3

# Run any pending migrations
echo "🗄️  Checking for database migrations..."
./vendor/bin/sail artisan migrate --force

echo "✅ Laravel backend started successfully!"
echo "   Backend running at: http://localhost"
echo ""

# Start Vue Frontend
echo "🚀 Starting Vue Frontend..."
echo "---------------------------"

# Capture the original directory so we can return to it
original_dir="$PWD"

cd ../vue-app

echo "📦 Starting development server..."
echo ""
echo "✅ Vue frontend will start shortly"
echo "   Frontend will be available at: http://localhost:5173/"
echo ""
echo "🎉 Application Ready!"
echo "===================="
echo "• Laravel Backend: http://localhost"
echo "• Vue Frontend: http://localhost:5173/"
echo ""
echo "💡 Press Ctrl+C to stop the Vue development server"
echo "💡 To stop Laravel: cd laravel-app && ./vendor/bin/sail down"
echo ""

# Set up a trap to return to original directory when script exits
trap "echo ''; echo '🔄 Returning to original directory...'; cd '$original_dir'" EXIT

# Start the Vue dev server (this will block until Ctrl+C)
npm run dev
