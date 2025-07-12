#!/bin/bash

# Make metro troubleshooting scripts executable
chmod +x install_metro_app.sh
chmod +x troubleshoot_redis.sh
chmod +x status_check.sh
chmod +x debug_laravel.sh  
chmod +x troubleshoot_mysql.sh
chmod +x start_metro_app.sh
chmod +x stop_metro_app.sh
chmod +x cleanup_metro.sh

echo "All Metro scripts are now executable!"

echo ""
echo "Available scripts:"
echo "• ./install_metro_app.sh       - Fixed installation with proper timing"
echo "• ./status_check.sh            - Quick health check of all services"
echo "• ./start_metro_app.sh          - Start all services"
echo "• ./stop_metro_app.sh           - Stop all services"
echo "• ./cleanup_metro.sh            - Complete cleanup and reset"
echo "• ./debug_laravel.sh            - Laravel diagnostics"
echo "• ./troubleshoot_mysql.sh       - MySQL diagnostics"
echo "• ./troubleshoot_redis.sh       - Redis diagnostics"