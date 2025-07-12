#!/bin/bash

echo "🧹 Metro App - Complete Cleanup"
echo "==============================="
echo ""

# Stop all containers
echo "🛑 Stopping all Metro containers..."
docker compose down --volumes --remove-orphans 2>/dev/null || echo "No containers to stop"

# Remove any Metro-related containers
echo "🗑️  Removing Metro containers..."
docker rm -f wmata-laravel wmata-vue wmata-mysql wmata-redis 2>/dev/null || echo "No specific containers to remove"

# Remove Metro networks
echo "🌐 Removing Metro networks..."
docker network rm wmata_network 2>/dev/null || echo "No Metro network to remove"

# Remove Metro volumes (ask first)
read -p "🗄️  Remove all Metro data (databases, cache)? This will delete ALL data! (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing Metro volumes..."
    docker volume rm wmata-app-test_mysql_data wmata-app-test_redis_data 2>/dev/null || echo "No volumes to remove"
    echo "✅ All data removed"
else
    echo "ℹ️  Data volumes preserved"
fi

# Show what's still using the conflicting ports
echo ""
echo "🔍 Checking what's using the standard ports..."
echo "Port 3306 (MySQL):"
lsof -i :3306 || echo "  No processes using port 3306"

echo ""
echo "Port 6379 (Redis):"
lsof -i :6379 || echo "  No processes using port 6379"

echo ""
echo "Port 80 (Web):"
lsof -i :80 || echo "  No processes using port 80"

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "🔧 Now you can apply the fixes and reinstall with non-standard ports:"
echo "   • Laravel: http://localhost:8080"
echo "   • Vue: http://localhost:5173"  
echo "   • MySQL: localhost:33066"
echo "   • Redis: localhost:63799"