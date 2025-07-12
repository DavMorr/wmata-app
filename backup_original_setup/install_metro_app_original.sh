#!/bin/bash

# Metro Train Predictions App - Initial Installation Script
# This script sets up the Laravel backend and Vue frontend for the first time

set -e  # Exit on any error

echo "🚇 Metro Train Predictions App - Initial Setup"
echo "=============================================="
echo ""

# Check if we're in the right directory
if [[ ! -d "laravel-app" ]] || [[ ! -d "vue-app" ]]; then
    echo "❌ Error: This script must be run from the project root directory"
    echo "   Make sure you're in the 'wmata-app' directory"
    exit 1
fi

# Check requirements
echo "🔍 Checking requirements..."

# Check for composer
if ! command -v composer &> /dev/null; then
    echo "❌ Error: Composer is not installed"
    echo "   Please install Composer: https://getcomposer.org/download/"
    exit 1
fi

# Check for docker
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    echo "   Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check for node/npm
if ! command -v npm &> /dev/null; then
    echo "❌ Error: Node.js/npm is not installed"
    echo "   Please install Node.js: https://nodejs.org/"
    exit 1
fi

echo "✅ All requirements met!"
echo ""

# Laravel Backend Setup
echo "🔧 Setting up Laravel Backend..."
echo "--------------------------------"

cd laravel-app

echo "📝 Setting up environment file..."
if [[ ! -f ".env" ]]; then
    cp .env.example .env
    echo "✅ Created .env file from .env.example"
else
    echo "⚠️  .env file already exists, skipping..."
fi

echo "🔧 Setting up Sail environment variables..."
# Set WWWUSER and WWWGROUP for proper Docker permissions
if ! grep -q "WWWUSER=" .env; then
    echo "WWWUSER=$(id -u)" >> .env
fi
if ! grep -q "WWWGROUP=" .env; then
    echo "WWWGROUP=$(id -g)" >> .env
fi

echo "📦 Installing PHP dependencies..."
composer install

echo "🐳 Starting Docker containers..."
./vendor/bin/sail up -d

echo "🔑 Generating application key..."
./vendor/bin/sail artisan key:generate

echo "🔑 Generating application key..."
./vendor/bin/sail artisan key:generate

echo "🗄️  Running database migrations..."
./vendor/bin/sail artisan migrate

echo "🌱 Seeding database..."
# Try to run seeders, but don't fail if WMATA API isn't configured yet
if ./vendor/bin/sail artisan db:seed; then
    echo "✅ Database seeding completed successfully"
else
    echo "⚠️  Database seeding failed (likely due to missing WMATA API configuration)"
    echo "   You can run 'sail artisan db:seed' manually after configuring the WMATA API"
fi

echo "📦 Installing Laravel frontend dependencies..."
./vendor/bin/sail npm install

echo "🛑 Shutting down Docker containers..."
./vendor/bin/sail down

echo "✅ Laravel backend setup complete!"
echo ""

# Vue Frontend Setup
echo "🔧 Setting up Vue Frontend..."
echo "-----------------------------"

cd ../vue-app

echo "📦 Installing Node dependencies..."
npm install

echo "🔧 Installing Vue plugin..."
npm install --save-dev @vitejs/plugin-vue

echo "🎨 Formatting code..."
npm run format

echo "✅ Vue frontend setup complete!"
echo ""

# Final instructions
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "✅ Laravel backend configured and ready"
echo "✅ Vue frontend configured and ready"
echo ""
echo "To start the application:"
echo "  ./start_metro_app.sh"
echo ""
echo "This will start both:"
echo "• Laravel backend at: http://localhost"
echo "• Vue frontend at: http://localhost:5173/"
echo ""
echo "💡 Tip: Run './setup-sail-alias.sh' to set up the sail command alias"