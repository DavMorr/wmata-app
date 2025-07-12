#!/bin/bash

# Metro Train Predictions App - Start Script
# Start the development environment

set -e  # Exit on any error

echo "Metro Train Predictions App - Starting"
echo "======================================"
echo ""

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo "ERROR: Please run this script from the wmata-app-test directory"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "ERROR: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check for port conflicts
echo "Checking for port conflicts..."
REQUIRED_PORTS=(8080 5173 33066 63799)
for port in "${REQUIRED_PORTS[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "  WARNING: Port $port is in use - stopping conflicting containers..."
        docker compose down 2>/dev/null || true
        break
    fi
done

# Start containers
echo ""
echo "Starting containers..."
echo "  This includes automatic Metro data sync on startup"
docker compose up -d

# Wait for services
echo ""
echo "Waiting for services to start..."
sleep 15

# Verify services
echo ""
echo "Verifying services..."
if curl -f http://localhost:8080/api/test &>/dev/null; then
    echo "  Laravel backend is ready"
else
    echo "  WARNING: Laravel backend not ready yet - may need more time"
fi

echo ""
echo "Services started successfully!"
echo "======================================"
echo "Laravel API:  http://localhost:8080"
echo "Vue Frontend: http://localhost:5173"  
echo "======================================"
echo ""
echo "Available commands:"
echo "  ./metro-stop.sh - Stop services"
echo "  docker compose logs -f - View logs"
echo "  metro sync - Manual Metro data sync (if using metro command)"
echo ""