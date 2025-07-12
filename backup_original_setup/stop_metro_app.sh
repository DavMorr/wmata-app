#!/bin/bash

# Metro Train Predictions App - Enhanced Stop Script
# This script stops all containerized services

echo "🛑 Stopping Metro Train Predictions App"
echo "======================================="
echo ""

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ Error: docker-compose.yml not found"
    echo "   Make sure you're in the project root directory (wmata-app-test)"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "⚠️  Docker is not running - services may already be stopped"
    exit 0
fi

# Check current service status
echo "🔍 Checking current service status..."
if ! docker compose ps | grep -q "Up"; then
    echo "ℹ️  All services are already stopped"
    echo ""
    echo "🎉 Metro app is already shut down!"
    exit 0
fi

echo "📋 Currently running services:"
docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Prompt for confirmation unless forced
if [[ "$1" != "--force" ]] && [[ "$1" != "-f" ]]; then
    read -p "🤔 Stop all Metro services? (Y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "❌ Cancelled - services remain running"
        exit 0
    fi
fi

# Stop the services
echo "🛑 Stopping Metro services..."
echo "=============================="

# Stop containers gracefully
echo "📦 Stopping containers..."
if docker compose down; then
    echo "✅ All containers stopped successfully"
else
    echo "⚠️  Some issues occurred while stopping containers"
    echo "   You may need to force stop with: docker compose down --force"
fi

# Optional: Remove volumes (ask user)
echo ""
read -p "🗄️  Remove database and cache data? This will delete all stored data! (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing volumes..."
    docker compose down --volumes
    echo "✅ Database and cache data removed"
    echo "⚠️  Note: You'll need to run 'metro install' to reinitialize the database"
else
    echo "ℹ️  Database and cache data preserved"
fi

# Clean up any orphaned containers
echo ""
echo "🧹 Cleaning up..."
if docker compose down --remove-orphans &>/dev/null; then
    echo "✅ Cleanup completed"
fi

# Show final status
echo ""
echo "📊 Final status check..."
if docker compose ps | grep -q "Up"; then
    echo "⚠️  Some services are still running:"
    docker compose ps
    echo ""
    echo "💡 To force stop everything:"
    echo "   docker compose down --force"
    echo "   docker compose down --volumes --remove-orphans  (removes all data)"
else
    echo "✅ All Metro services stopped successfully"
fi

echo ""
echo "🎉 Metro app shutdown complete!"
echo ""
echo "🚀 To start again:"
echo "   metro up"
echo "   (or docker compose up -d)"
echo ""
echo "🔧 Useful commands:"
echo "   docker compose ps              # Check service status"
echo "   docker compose logs           # View all logs"
echo "   docker system prune           # Clean up Docker resources"
echo "   docker volume ls              # List Docker volumes"
echo ""

# Show resource usage summary
echo "💾 Docker resource summary:"
echo "   Containers: $(docker ps -a --format '{{.Names}}' | grep wmata | wc -l || echo '0') total"
echo "   Volumes:    $(docker volume ls --format '{{.Name}}' | grep wmata | wc -l || echo '0') total"
echo "   Networks:   $(docker network ls --format '{{.Name}}' | grep wmata | wc -l || echo '0') total"
echo ""
echo "Thank you for using Metro Train Predictions! 🚇"