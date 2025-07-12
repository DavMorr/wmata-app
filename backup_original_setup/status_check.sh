#!/bin/bash

# Quick Metro App Status Check
echo "Metro Train Predictions App - Status Check"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running"
    exit 1
fi

echo "1. Container Status:"
echo "==================="
docker compose ps
echo ""

echo "2. Service Health Summary:"
echo "=========================="

# Check each service
services=("mysql" "redis" "laravel-backend" "vue-frontend")
for service in "${services[@]}"; do
    if docker compose ps "$service" | grep -q "Up"; then
        if docker compose ps "$service" | grep -q "healthy"; then
            echo "✅ $service: Running and Healthy"
        else
            echo "⚠️  $service: Running (no health check)"
        fi
    else
        echo "❌ $service: Not Running"
    fi
done

echo ""
echo "3. API Connectivity Tests:"
echo "=========================="

# Test Laravel API
echo -n "Laravel API (http://localhost:8080/api/test): "
if curl -s -f http://localhost:8080/api/test >/dev/null 2>&1; then
    echo "✅ Responding"
else
    echo "❌ Not responding"
fi

# Test Vue frontend
echo -n "Vue Frontend (http://localhost:5173): "
if curl -s -f http://localhost:5173 >/dev/null 2>&1; then
    echo "✅ Responding"
else
    echo "❌ Not responding"
fi

echo ""
echo "4. Database Connectivity:"
echo "========================="
echo -n "MySQL Connection: "
if docker compose exec mysql mysql -u root -ppassword -e "SELECT 'Connected' as status;" 2>/dev/null | grep -q "Connected"; then
    echo "✅ Database Connected"
else
    echo "❌ Database Connection Failed"
fi

echo ""
echo "5. Port Status:"
echo "==============="
ports=(8080 5173 33066 63799)
port_names=("Laravel" "Vue" "MySQL" "Redis")

for i in "${!ports[@]}"; do
    port=${ports[i]}
    name=${port_names[i]}
    echo -n "$name (port $port): "
    if lsof -Pi ":$port" -sTCP:LISTEN >/dev/null 2>&1; then
        echo "✅ Listening"
    else
        echo "❌ Not listening"
    fi
done

echo ""
echo "6. Quick URLs:"
echo "=============="
echo "• Vue Frontend:    http://localhost:5173"
echo "• Laravel Backend: http://localhost:8080"
echo "• API Test:        http://localhost:8080/api/test"

echo ""
if docker compose ps | grep -q "Up"; then
    echo "🎉 Metro Train Predictions App is OPERATIONAL!"
else
    echo "⚠️  Some services may need attention"
fi