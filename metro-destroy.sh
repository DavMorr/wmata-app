#!/bin/bash

# Metro Train Predictions App - Complete Teardown
# Removes all containers, volumes, networks, and resets to clean state

set -e

echo "Metro Train Predictions App - Complete Teardown"
echo "=============================================="
echo ""
echo "WARNING: This will completely destroy the Metro application and all data!"
echo "  All Docker containers will be removed"
echo "  All databases and cache data will be deleted"
echo "  All Docker images will be removed"
echo "  Local environment files will be reset"
echo ""

# Confirmation prompt
read -p "Are you sure you want to completely destroy everything? (type 'destroy' to confirm): " confirmation
echo ""

if [[ "$confirmation" != "destroy" ]]; then
    echo "Teardown cancelled - nothing was destroyed"
    exit 0
fi

echo "Starting complete teardown..."
echo ""

# Stop and remove all containers, volumes, networks, and orphans
echo "Stopping and removing all Metro containers..."
docker compose down --volumes --remove-orphans --rmi all 2>/dev/null || echo "  No containers to stop"

# Remove any remaining Metro containers by name
echo "Removing any remaining Metro containers..."
docker rm -f wmata-laravel wmata-vue wmata-mysql wmata-redis 2>/dev/null || echo "  No specific containers found"

# Remove Metro networks
echo "Removing Metro networks..."
docker network rm wmata_network 2>/dev/null || echo "  No Metro network found"

# Remove Metro volumes explicitly
echo "Removing Metro data volumes..."
docker volume rm wmata-app-test_mysql_data wmata-app-test_redis_data 2>/dev/null || echo "  No volumes found"

# Remove Docker images related to Metro app
echo "Removing Metro Docker images..."
docker rmi wmata-app-test-laravel-backend wmata-app-test-vue-frontend 2>/dev/null || echo "  No Metro images found"

# Clean up environment files
echo "Resetting environment files..."

# Reset Laravel .env
if [[ -f "laravel-app/.env" ]]; then
    echo "  Removing laravel-app/.env"
    rm laravel-app/.env
fi

# Reset Vue .env  
if [[ -f "vue-app/.env" ]]; then
    echo "  Removing vue-app/.env"
    rm vue-app/.env
fi

# Remove node_modules if present (handle Docker permission issues)
if [[ -d "vue-app/node_modules" ]]; then
    echo "  Removing Vue node_modules..."
    if rm -rf vue-app/node_modules 2>/dev/null; then
        echo "    Successfully removed node_modules"
    else
        echo "    Permission issue detected - using sudo to remove Docker-created files"
        sudo rm -rf vue-app/node_modules
        echo "    Successfully removed node_modules with elevated permissions"
    fi
fi

# Remove package-lock if present
if [[ -f "vue-app/package-lock.json" ]]; then
    echo "  Removing Vue package-lock.json"
    rm vue-app/package-lock.json
fi

# Clean Docker system (optional)
echo ""
read -p "Also clean unused Docker resources system-wide? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleaning Docker system..."
    docker system prune -f
    echo "Docker system cleaned"
fi

# Verify teardown
echo ""
echo "Verifying teardown..."

# Check if any containers are still running
RUNNING_CONTAINERS=$(docker ps --filter "name=wmata" --format "table {{.Names}}" | tail -n +2)
if [[ -n "$RUNNING_CONTAINERS" ]]; then
    echo "WARNING: Some Metro containers may still be running:"
    echo "$RUNNING_CONTAINERS"
else
    echo "  No Metro containers running"
fi

# Check volumes
REMAINING_VOLUMES=$(docker volume ls --filter "name=wmata" --format "{{.Name}}" 2>/dev/null)
if [[ -n "$REMAINING_VOLUMES" ]]; then
    echo "WARNING: Some Metro volumes may remain:"
    echo "$REMAINING_VOLUMES"
else
    echo "  No Metro volumes found"
fi

# Check ports
echo ""
echo "Checking if ports are now free..."
PORTS=(8080 5173 33066 63799)
for port in "${PORTS[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "  WARNING: Port $port is still in use"
    else
        echo "  Port $port is free"
    fi
done

echo ""
echo "TEARDOWN COMPLETE!"
echo "=============================================="
echo ""
echo "The application has been completely destroyed and reset."
echo "You can now:"
echo "  Share this directory with others for clean installation"
echo "  Run './metro-install.sh' for fresh setup"
echo "  Archive this directory as a clean distribution"
echo ""
echo "Project is now in clean state for distribution"
echo ""