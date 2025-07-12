#!/bin/bash

# Metro Train Predictions App - Stop Script
# Stop all services

echo "Metro Train Predictions App - Stopping"
echo "======================================"
echo ""

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo "ERROR: Please run this script from the wmata-app-test directory"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "WARNING: Docker is not running - services may already be stopped"
    exit 0
fi

# Stop containers
echo "Stopping containers..."
docker compose down

# Show status
echo ""
echo "Container status:"
docker compose ps

echo ""
echo "Services stopped successfully!"
echo "======================================"
echo ""
echo "Available commands:"
echo "  ./metro-start.sh - Start services"
echo "  ./metro-install.sh - Fresh installation"
echo "  ./metro-reset.sh - Reset with fresh data"
echo "  docker compose down --volumes - Remove all data"
echo ""