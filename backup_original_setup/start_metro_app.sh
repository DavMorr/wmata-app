#!/bin/bash

# Metro Train Predictions App - Enhanced Startup Script
# This script starts the containerized Laravel backend and Vue frontend

set -e  # Exit on any error

echo "🚇 Metro Train Predictions App - Starting Services"
echo "================================================="
echo ""

# Check if we're in the right directory
if [[ ! -d "laravel-app" ]] || [[ ! -d "vue-app" ]] || [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ Error: This script must be run from the project root directory"
    echo "   Make sure you're in the wmata-app-test directory and have run 'metro install' first"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker is not running"
    echo "   Please start Docker and try again"
    exit 1
fi

# Function to check if a service is healthy
check_service_health() {
    local service_name="$1"
    local max_attempts=30
    local attempt=1
    
    echo "🔍 Checking $service_name health..."
    
    while [ $attempt -le $max_attempts ]; do
        local health_status
        health_status=$(docker compose ps --format json | jq -r ".[] | select(.Service == \"$service_name\") | .Health")
        
        case $health_status in
            "healthy")
                echo "✅ $service_name is healthy!"
                return 0
                ;;
            "starting")
                echo "   Attempt $attempt/$max_attempts: $service_name is starting..."
                ;;
            "unhealthy")
                echo "⚠️  $service_name is unhealthy"
                return 1
                ;;
            *)
                echo "   Attempt $attempt/$max_attempts: Waiting for $service_name..."
                ;;
        esac
        
        sleep 2
        ((attempt++))
    done
    
    echo "⚠️  $service_name health check timed out"
    return 1
}

# Function to check if port is in use (excluding Docker)
check_port_conflict() {
    local port=$1
    local process
    process=$(lsof -Pi :$port -sTCP:LISTEN | grep -v "com.docker" | head -n1 || true)
    
    if [[ -n "$process" ]]; then
        echo "⚠️  Warning: Port $port is in use by a non-Docker process:"
        echo "   $process"
        read -p "   Continue anyway? This may cause conflicts. (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Check for port conflicts
echo "🔍 Checking for port conflicts..."
check_port_conflict 80 || exit 1
check_port_conflict 5173 || exit 1
check_port_conflict 3306 || exit 1
check_port_conflict 6379 || exit 1

echo "✅ No port conflicts detected"
echo ""

# Check if services are already running
echo "🔍 Checking service status..."
if docker compose ps | grep -q "Up"; then
    echo "ℹ️  Some services are already running"
    read -p "   Would you like to restart all services? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Restarting services..."
        docker compose down
        sleep 2
    else
        echo "ℹ️  Using existing running services..."
    fi
fi

# Start the services
echo "🚀 Starting Metro Train Predictions App..."
echo "=========================================="

echo "🐳 Starting Docker containers..."
docker compose up -d

echo ""
echo "⏳ Waiting for services to initialize..."

# Wait for database first (other services depend on it)
if ! check_service_health "mysql"; then
    echo "❌ Database failed to start properly"
    echo "   Check logs with: docker compose logs mysql"
    exit 1
fi

# Wait for Redis
if ! check_service_health "redis"; then
    echo "❌ Redis failed to start properly"
    echo "   Check logs with: docker compose logs redis"
    exit 1
fi

# Wait for Laravel backend
if ! check_service_health "laravel-backend"; then
    echo "❌ Laravel backend failed to start properly"
    echo "   Check logs with: docker compose logs laravel-backend"
    exit 1
fi

# Check Vue frontend (it doesn't have health checks, so check if container is running)
echo "🔍 Checking Vue frontend..."
if docker compose ps vue-frontend | grep -q "Up"; then
    echo "✅ Vue frontend container is running!"
else
    echo "❌ Vue frontend container is not running"
    echo "   Check logs with: docker compose logs vue-frontend"
    exit 1
fi

# Final connectivity tests
echo ""
echo "🔗 Testing API connectivity..."

# Test Laravel API
if curl -s -f http://localhost/api/test &>/dev/null; then
    echo "✅ Laravel API is responding!"
else
    echo "⚠️  Laravel API test failed, but container is running"
    echo "   The API might still be initializing. Check logs if issues persist."
fi

# Test Vue frontend
if curl -s -f http://localhost:5173 &>/dev/null; then
    echo "✅ Vue frontend is responding!"
else
    echo "⚠️  Vue frontend test failed, but container is running"
    echo "   The frontend might still be building. Check logs if issues persist."
fi

echo ""
echo "🎉 Metro Train Predictions App Started Successfully!"
echo "=================================================="
echo ""
echo "🌐 Application URLs:"
echo "• Vue Frontend:    http://localhost:5173/"
echo "• Laravel Backend: http://localhost/"
echo "• API Endpoint:    http://localhost/api/"
echo "• API Test:        http://localhost/api/test"
echo ""
echo "🗄️  Database & Cache:"
echo "• MySQL:  localhost:3306 (user: sail, password: password, db: laravel)"
echo "• Redis:  localhost:6379"
echo ""
echo "🛠️  Management Commands:"
echo "• View all logs:        docker compose logs"
echo "• View service logs:    docker compose logs [service-name]"
echo "• Stop services:        metro down"
echo "• Restart services:     metro up"
echo "• Service status:       docker compose ps"
echo ""
echo "🔧 Development Commands:"
echo "• Laravel shell:        docker compose exec laravel-backend bash"
echo "• Vue shell:            docker compose exec vue-frontend sh"
echo "• Run migrations:       docker compose exec laravel-backend php artisan migrate"
echo "• Laravel commands:     docker compose exec laravel-backend php artisan [command]"
echo ""
echo "💡 The Vue development server supports hot reloading - your changes will appear automatically!"
echo ""
echo "🚇 Happy Metro development!"