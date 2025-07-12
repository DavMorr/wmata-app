#!/bin/bash

# Debug Laravel Container Startup Issues
# Run this to diagnose why Laravel container is failing health checks

echo "Metro Laravel Container Diagnostic"
echo "=================================="
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running"
    exit 1
fi

# Check container status
echo "1. Container Status:"
docker compose ps

echo ""
echo "2. Laravel Container Logs (last 50 lines):"
docker compose logs --tail=50 laravel-backend

echo ""
echo "3. Testing Laravel Health Check Endpoint:"
if docker compose ps laravel-backend | grep -q "Up"; then
    echo "Container is running, testing health endpoint..."
    
    # Test internal health check
    echo "Internal health check:"
    docker compose exec laravel-backend curl -f http://localhost/api/test 2>/dev/null || echo "FAILED: Internal health check failed"
    
    # Test external access
    echo "External health check:"
    curl -f http://localhost:8080/api/test 2>/dev/null || echo "FAILED: External health check failed"
    
    # Check Apache status
    echo ""
    echo "4. Apache Status Inside Container:"
    docker compose exec laravel-backend ps aux | grep apache || echo "Apache not running"
    
    # Check Laravel environment
    echo ""
    echo "5. Laravel Environment Check:"
    docker compose exec laravel-backend php artisan --version || echo "Laravel not accessible"
    
    # Check database connection
    echo ""
    echo "6. Database Connection Test:"
    docker compose exec laravel-backend php artisan migrate:status || echo "Database connection failed"
    
else
    echo "Container is not running"
fi

echo ""
echo "7. Port Conflicts Check:"
echo "Port 8080 (Laravel):"
lsof -i :8080 || echo "No conflicts on port 8080"

echo ""
echo "8. Docker Network Inspection:"
docker network inspect wmata_network --format='{{json .Containers}}' | jq . 2>/dev/null || echo "Network inspection failed"

echo ""
echo "Diagnostic complete. Review output above for issues."