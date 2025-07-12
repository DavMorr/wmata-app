#!/bin/bash

# Redis Troubleshooting Script for Metro App

echo "Redis Container Troubleshooting"
echo "==============================="
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running"
    exit 1
fi

echo "1. Current Container Status:"
docker compose ps redis

echo ""
echo "2. Redis Container Health Details:"
docker inspect wmata-redis --format='{{.State.Health.Status}}: {{.State.Health.Log}}' 2>/dev/null || echo "Health check not available"

echo ""
echo "3. Redis Container Logs (last 30 lines):"
docker compose logs --tail=30 redis

echo ""
echo "4. Test Redis Connection from Container:"
echo "Testing Redis connectivity..."
if docker compose exec redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
    echo "SUCCESS: Redis responding to PING"
    
    # Test basic operations
    echo "Testing basic Redis operations..."
    docker compose exec redis redis-cli set test_key "test_value" >/dev/null 2>&1
    if docker compose exec redis redis-cli get test_key 2>/dev/null | grep -q "test_value"; then
        echo "SUCCESS: Redis read/write operations working"
        docker compose exec redis redis-cli del test_key >/dev/null 2>&1
    else
        echo "ERROR: Redis read/write operations failed"
    fi
else
    echo "ERROR: Redis not responding to PING"
fi

echo ""
echo "5. Test Laravel Redis Connection:"
echo "Testing Laravel-to-Redis connectivity..."
if docker compose exec laravel-backend php -r "
try {
    \$redis = new Redis();
    \$redis->connect('redis', 6379);
    \$redis->set('laravel_test', 'working');
    \$result = \$redis->get('laravel_test');
    \$redis->del('laravel_test');
    if (\$result === 'working') {
        echo 'SUCCESS: Laravel can connect to Redis\n';
    } else {
        echo 'ERROR: Laravel Redis operations failed\n';
    }
} catch (Exception \$e) {
    echo 'ERROR: ' . \$e->getMessage() . '\n';
}" 2>/dev/null; then
    echo "Laravel Redis test completed"
else
    echo "ERROR: Could not run Laravel Redis test"
fi

echo ""
echo "6. Check Port 63799 Availability:"
lsof -i :63799 || echo "No processes listening on port 63799"

echo ""
echo "7. Redis Process Check Inside Container:"
docker compose exec redis ps aux | grep redis || echo "No Redis processes found"

echo ""
echo "8. Redis Configuration Check:"
docker compose exec redis redis-cli config get "*" 2>/dev/null | head -20 || echo "Could not check Redis configuration"

echo ""
echo "9. Redis Memory Info:"
docker compose exec redis redis-cli info memory 2>/dev/null | grep -E "(used_memory|maxmemory)" || echo "Could not get memory info"

echo ""
echo "Troubleshooting complete."
echo ""
echo "Common Solutions:"
echo "1. Restart Redis: docker compose restart redis"
echo "2. Restart all services: docker compose restart"
echo "3. Check Redis logs: docker compose logs redis"
echo "4. Reset Redis data: docker compose down --volumes && docker compose up -d"