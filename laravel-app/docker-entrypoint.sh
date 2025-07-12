#!/bin/bash
set -e

echo "🚇 WMATA Metro App - Container Initialization"
echo "=============================================="

# Wait for database
echo "⏳ Waiting for database connection..."
while ! php -r "new PDO(\"mysql:host=mysql;dbname=laravel\", \"sail\", \"password\");" 2>/dev/null; do
    echo "   Waiting for database..."
    sleep 2
done
echo "✅ Database connected!"

# Run migrations if not in production
if [ "$APP_ENV" != "production" ]; then
    echo "🔄 Running database migrations..."
    php artisan migrate --force
    echo "✅ Migrations completed!"
fi

# Sync Metro data from WMATA API
echo "🚇 Syncing Metro data from WMATA API..."
if php artisan metro:sync; then
    echo "✅ Metro data sync completed!"
else
    echo "⚠️  Metro data sync failed, but continuing..."
    echo "   You can run 'docker compose exec laravel-backend php artisan metro:sync' manually"
fi

# Clear any stale cache
echo "🧹 Clearing application cache..."
php artisan cache:clear
php artisan config:clear
echo "✅ Cache cleared!"

echo "🚀 Starting Apache web server..."
echo "=============================================="
echo "📍 Laravel API: http://localhost:8080"
echo "📍 Vue Frontend: http://localhost:5173"
echo "=============================================="

# Start Apache
exec apache2-foreground