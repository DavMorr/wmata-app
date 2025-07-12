#!/bin/bash

# MySQL Troubleshooting Script for Metro App

echo "MySQL Container Troubleshooting"
echo "==============================="
echo ""

# Check current container status
echo "1. Current Container Status:"
docker compose ps mysql

echo ""
echo "2. MySQL Container Health Details:"
docker inspect wmata-mysql --format='{{.State.Health.Status}}: {{.State.Health.Log}}' 2>/dev/null || echo "Health check not available"

echo ""
echo "3. MySQL Container Logs (last 30 lines):"
docker compose logs --tail=30 mysql

echo ""
echo "4. Test MySQL Connection from Laravel Container:"
echo "Testing database connectivity..."
if docker compose exec laravel-backend php -r "
try {
    \$pdo = new PDO('mysql:host=mysql;dbname=laravel', 'sail', 'password');
    echo 'SUCCESS: Database connection established\n';
    \$result = \$pdo->query('SELECT VERSION()')->fetchColumn();
    echo 'MySQL Version: ' . \$result . '\n';
} catch (Exception \$e) {
    echo 'ERROR: ' . \$e->getMessage() . '\n';
}"; then
    echo "Database test completed"
else
    echo "ERROR: Could not run database test"
fi

echo ""
echo "5. Test External MySQL Connection:"
if command -v mysql >/dev/null 2>&1; then
    echo "Testing external connection to localhost:33066..."
    mysql -h 127.0.0.1 -P 33066 -u sail -ppassword -e "SELECT 'Connection successful' as status;" 2>/dev/null || echo "External connection failed"
else
    echo "MySQL client not available for external test"
fi

echo ""
echo "6. Check Port 33066 Availability:"
lsof -i :33066 || echo "No processes listening on port 33066"

echo ""
echo "7. MySQL Process Check Inside Container:"
docker compose exec mysql ps aux | grep mysql || echo "No MySQL processes found"

echo ""
echo "8. MySQL Configuration Check:"
docker compose exec mysql mysql -u root -ppassword -e "SHOW VARIABLES LIKE 'bind_address';" 2>/dev/null || echo "Could not check MySQL configuration"

echo ""
echo "Troubleshooting complete."
echo ""
echo "Common Solutions:"
echo "1. Restart MySQL: docker compose restart mysql"
echo "2. Restart all services: docker compose restart"
echo "3. Check MySQL logs: docker compose logs mysql"
echo "4. Reset MySQL data: docker compose down --volumes && docker compose up -d"