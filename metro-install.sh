#!/bin/bash

# Metro Train Predictions App - Installation Script
# First-time setup for the containerized Laravel + Vue application

set -e  # Exit on any error

echo "Metro Train Predictions App - Installation"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [[ ! -d "laravel-app" ]] || [[ ! -d "vue-app" ]] || [[ ! -f "docker-compose.yml" ]]; then
    echo "ERROR: Please run this script from the wmata-app-test directory"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "ERROR: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check Node.js version
echo "Checking Node.js version..."
NODE_VERSION=$(node --version 2>/dev/null || echo "none")
if [[ "$NODE_VERSION" == "none" ]]; then
    echo "ERROR: Node.js is not installed. Please install Node.js and try again."
    echo "       Download from: https://nodejs.org/"
    exit 1
fi

echo "  Node.js version: $NODE_VERSION"

# Parse Node version for compatibility check
NODE_MAJOR=$(echo $NODE_VERSION | sed 's/v\([0-9]*\)\..*/\1/')
NODE_MINOR=$(echo $NODE_VERSION | sed 's/v[0-9]*\.\([0-9]*\)\..*/\1/')
NODE_PATCH=$(echo $NODE_VERSION | sed 's/v[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/')

# Check if Node version meets requirements (18.19.0+ or 20.5.0+)
VERSION_OK=false
if [[ $NODE_MAJOR -gt 20 ]]; then
    VERSION_OK=true
elif [[ $NODE_MAJOR -eq 20 && $NODE_MINOR -ge 5 ]]; then
    VERSION_OK=true
elif [[ $NODE_MAJOR -eq 18 && $NODE_MINOR -ge 19 ]]; then
    VERSION_OK=true
fi

if [[ "$VERSION_OK" == "false" ]]; then
    echo "  WARNING: Node.js version compatibility issue detected"
    echo "           Current: $NODE_VERSION"
    echo "           Required: v18.19.0+ or v20.5.0+"
    echo ""
    echo "  Auto-fixing: Using compatible package versions for older Node.js..."
    
    # Use compatible package.json for older Node versions
    if [[ -f "vue-app/package-compatible.json" ]]; then
        echo "    Switching to Node.js v18.12.x compatible packages..."
        cp vue-app/package.json vue-app/package-original.json
        cp vue-app/package-compatible.json vue-app/package.json
        echo "    Compatible packages configured"
    fi
else
    echo "  Node.js version is compatible"
fi

# Check for required ports
echo ""
echo "Checking for port conflicts..."
REQUIRED_PORTS=(8080 5173 33066 63799)
for port in "${REQUIRED_PORTS[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "ERROR: Port $port is already in use. Please stop the conflicting service."
        echo "       Run: lsof -i :$port to see what's using it"
        exit 1
    fi
done
echo "  All required ports are available"

# Set up Laravel environment
echo ""
echo "Setting up Laravel environment..."
if [[ ! -f "laravel-app/.env" ]]; then
    echo "  Copying .env.example to .env..."
    cp laravel-app/.env.example laravel-app/.env
fi

# Set up Vue environment  
echo ""
echo "Setting up Vue environment..."
if [[ ! -f "vue-app/.env" ]]; then
    echo "  Creating Vue .env file..."
    cat > vue-app/.env << 'EOF'
# Laravel API Base URL - CORRECTED PORT
VITE_API_BASE_URL=http://localhost:8080/api
VITE_API_URL=http://localhost:8080/api

# Development settings
VITE_APP_NAME="Metro Transit Predictor"
VITE_PREDICTIONS_REFRESH_INTERVAL=30

# Development mode settings
VITE_APP_DEBUG=true
VITE_APP_ENV=development
EOF
fi

# Install Vue dependencies
echo ""
echo "Installing Vue dependencies..."
echo "  This may take a few minutes on first run..."
echo "  NOTE: Cypress testing framework is NOT installed by default"
echo "        Run 'npm run test:install' in vue-app/ if you need testing"
cd vue-app

# Clean any existing node_modules and lock file (handle Docker permission issues)
if [[ -d "node_modules" ]]; then
    echo "  Cleaning existing node_modules..."
    if rm -rf node_modules 2>/dev/null; then
        echo "    Successfully removed node_modules"
    else
        echo "    Permission issue detected - using sudo to remove Docker-created files"
        sudo rm -rf node_modules
        echo "    Successfully removed node_modules with elevated permissions"
    fi
fi
if [[ -f "package-lock.json" ]]; then
    echo "  Removing existing package-lock.json..."
    rm package-lock.json
fi

# Install with appropriate flags for compatibility
if [[ "$VERSION_OK" == "false" ]]; then
    echo "  Installing with legacy peer deps for compatibility..."
    npm install --legacy-peer-deps --progress=false --no-audit
else
    echo "  Installing with standard configuration..."
    npm install --progress=false --no-audit
fi

cd ..

# Build and start containers
echo ""
echo "Building and starting containers..."
echo "  This includes automatic Metro data sync on startup"
docker compose up -d --build

# Wait for services to be ready
echo ""
echo "Waiting for services to initialize..."
echo "  Container startup may take 30-60 seconds on first run..."

# Wait longer for first build
sleep 30

# Generate Laravel application key
echo ""
echo "Generating Laravel application key..."
if docker compose exec laravel-backend php artisan key:generate; then
    echo "  Laravel application key generated successfully"
else
    echo "  WARNING: Failed to generate Laravel key - you may need to run this manually:"
    echo "           docker compose exec laravel-backend php artisan key:generate"
fi

# Check Laravel health
echo ""
echo "Verifying installation..."
MAX_ATTEMPTS=10
ATTEMPT=1
while [[ $ATTEMPT -le $MAX_ATTEMPTS ]]; do
    if curl -f http://localhost:8080/api/test &>/dev/null; then
        echo "  Laravel backend is responding"
        break
    else
        echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - Laravel not ready yet..."
        sleep 5
        ((ATTEMPT++))
    fi
done

if [[ $ATTEMPT -gt $MAX_ATTEMPTS ]]; then
    echo "  WARNING: Laravel backend not responding yet - may need more time"
    echo "           Check logs with: docker compose logs laravel-backend"
fi

# Check if package.json was modified
if [[ -f "vue-app/package-original.json" ]]; then
    echo ""
    echo "NOTE: Vue package.json was modified for Node.js compatibility"
    echo "      Original saved as: vue-app/package-original.json"
    echo "      To upgrade Node.js later: https://nodejs.org/"
fi

echo ""
echo "Installation completed successfully!"
echo "=========================================="
echo "Laravel API:  http://localhost:8080"
echo "Vue Frontend: http://localhost:5173"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  Visit http://localhost:5173 to use the app"
echo "  Use './metro-start.sh' to start in the future"
echo "  Use './metro-stop.sh' to stop services"
echo ""
if [[ "$VERSION_OK" == "false" ]]; then
    echo "TIP: Consider upgrading Node.js to v20+ for latest features"
    echo "     Current version: $NODE_VERSION"
    echo ""
fi