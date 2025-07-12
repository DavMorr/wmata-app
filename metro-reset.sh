#!/bin/bash

# Metro Train Predictions App - Quick Reset
# Stops containers and clears data but preserves images for faster restart

echo "Metro Train Predictions App - Quick Reset"
echo "========================================"
echo ""
echo "This will:"
echo "  Stop all Metro containers"
echo "  Clear all database and cache data"
echo "  Keep Docker images for faster restart"
echo ""

read -p "Proceed with reset? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Reset cancelled"
    exit 0
fi

echo "Resetting Metro application..."
echo ""

# Stop containers and remove volumes
echo "Stopping containers and clearing data..."
docker compose down --volumes

# Remove specific volumes to ensure clean data
echo "Removing data volumes..."
docker volume rm wmata-app-test_mysql_data wmata-app-test_redis_data 2>/dev/null || echo "  No volumes to remove"

# Clear Laravel cache/config if containers were running
echo "Application reset complete"

echo ""
echo "Reset completed successfully!"
echo "========================================"
echo ""
echo "Application reset with fresh data."
echo "Next steps:"
echo "  Run './metro-start.sh' to restart with fresh data"
echo "  All Metro data will sync automatically on startup"
echo ""