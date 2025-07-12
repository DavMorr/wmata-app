#!/bin/bash

# Metro Train Predictions App - Stop Script
# This script stops the Laravel backend and provides info about stopping Vue frontend

echo "🛑 Stopping Metro Train Predictions App..."
echo "=========================================="

# Check if we're in the right directory
if [[ ! -d "laravel-app" ]] && [[ ! -d "../laravel-app" ]]; then
    echo "❌ Error: Cannot find laravel-app directory"
    echo "   Make sure you're in the project root or laravel-app directory"
    exit 1
fi

# Navigate to the correct directory
if [[ -d "laravel-app" ]]; then
    # We're in project root
    cd laravel-app
elif [[ -d "../laravel-app" ]]; then
    # We're in a subdirectory, go to project root then laravel-app
    cd ../laravel-app
fi

echo "🐳 Stopping Laravel backend..."
if ./vendor/bin/sail ps 2>/dev/null | grep -q "Up"; then
    ./vendor/bin/sail down
    echo "✅ Laravel backend stopped successfully"
else
    echo "ℹ️  Laravel backend was already stopped"
fi

# Check for Vue frontend processes and provide guidance
echo ""
echo "📱 Vue Frontend Status:"
if pgrep -f "npm.*run.*dev\|vite.*dev\|node.*vite" >/dev/null 2>&1; then
    echo "⚠️  Vue frontend is still running"
    echo "   To stop it: Press Ctrl+C in the terminal where 'npm run dev' is running"
    
    # Show which processes are running
    echo ""
    echo "🔍 Vue-related processes:"
    pgrep -f "npm.*run.*dev\|vite.*dev\|node.*vite" | xargs ps -p 2>/dev/null || echo "   Process details not available"
    
    echo ""
    echo "💡 To force kill Vue processes (if needed):"
    echo "   pkill -f 'npm.*run.*dev'"
    echo "   pkill -f 'vite.*dev'"
else
    echo "✅ Vue frontend is stopped"
fi

echo ""
echo "🎉 Metro app shutdown complete!"
echo ""
echo "💡 To start again: metro up (or ./start_metro_app.sh)"