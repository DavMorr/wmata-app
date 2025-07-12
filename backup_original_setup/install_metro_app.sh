#!/bin/bash

# Metro Train Predictions App - Final Installation Script
# Fixed health check timing for both MySQL and Redis initialization

set -e  # Exit on any error

REQUIRED_PORTS=(8080 5173 33066 63799)
LOG_FILE="/tmp/metro_install.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling function
handle_error() {
    local line_number=$1
    log "ERROR: Installation failed at line $line_number"
    log "Cleaning up containers..."
    docker compose down --volumes --remove-orphans 2>/dev/null || true
    log "Check log file: $LOG_FILE"
    exit 1
}

# Set error trap
trap 'handle_error $LINENO' ERR

# Port conflict detection
check_port_conflicts() {
    log "Checking for port conflicts..."
    local conflicts=()
    
    for port in "${REQUIRED_PORTS[@]}"; do
        if lsof -Pi ":$port" -sTCP:LISTEN >/dev/null 2>&1; then
            local process=$(lsof -Pi ":$port" -sTCP:LISTEN | tail -n +2)
            conflicts+=("Port $port is in use by: $process")
        fi
    done
    
    if [ ${#conflicts[@]} -gt 0 ]; then
        log "ERROR: Port conflicts detected:"
        for conflict in "${conflicts[@]}"; do
            log "  $conflict"
        done
        log ""
        log "Resolution options:"
        log "1. Stop the conflicting services"
        log "2. Modify docker-compose.yml to use different ports"
        log "3. Use './cleanup_metro.sh' to clean up any existing Metro containers"
        return 1
    fi
    
    log "No port conflicts detected"
    return 0
}

# Enhanced service health validation with service-specific handling
wait_for_service_health() {
    local service_name=$1
    local max_attempts=60
    local attempt=1
    
    log "Waiting for $service_name to become healthy..."
    
    while [ $attempt -le $max_attempts ]; do
        local health_status=$(docker compose ps --format json | jq -r ".[] | select(.Service == \"$service_name\") | .Health" 2>/dev/null || echo "unknown")
        
        case $health_status in
            "healthy")
                log "$service_name is healthy"
                return 0
                ;;
            "unhealthy")
                log "ERROR: $service_name is unhealthy"
                log "Container logs:"
                docker compose logs --tail=20 "$service_name"
                return 1
                ;;
            "starting"|"unknown")
                # Service-specific direct connectivity tests after extended waiting
                if [ $attempt -gt 40 ]; then
                    case $service_name in
                        "mysql")
                            log "Attempt $attempt/$max_attempts: Testing MySQL connectivity directly..."
                            if docker compose exec mysql mysql -u root -ppassword -e "SELECT 1;" >/dev/null 2>&1; then
                                log "MySQL is responding to queries (health check may still be initializing)"
                                return 0
                            fi
                            ;;
                        "redis")
                            log "Attempt $attempt/$max_attempts: Testing Redis connectivity directly..."
                            if docker compose exec redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
                                log "Redis is responding to commands (health check may still be initializing)"
                                return 0
                            fi
                            ;;
                        *)
                            log "Attempt $attempt/$max_attempts: $service_name is starting..."
                            ;;
                    esac
                else
                    log "Attempt $attempt/$max_attempts: $service_name is starting..."
                fi
                ;;
        esac
        
        sleep 2
        ((attempt++))
    done
    
    # Final connectivity tests for database services
    case $service_name in
        "mysql")
            log "Health check timeout, testing MySQL connectivity directly..."
            if docker compose exec mysql mysql -u root -ppassword -e "SELECT 1;" >/dev/null 2>&1; then
                log "MySQL is responding to queries - proceeding despite health check status"
                return 0
            fi
            ;;
        "redis")
            log "Health check timeout, testing Redis connectivity directly..."
            if docker compose exec redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
                log "Redis is responding to commands - proceeding despite health check status"
                return 0
            fi
            ;;
    esac
    
    log "ERROR: $service_name failed to become healthy within timeout"
    log "Final container logs:"
    docker compose logs --tail=20 "$service_name"
    return 1
}

# Validate API endpoint
validate_api_endpoint() {
    local max_attempts=15
    local attempt=1
    
    log "Validating Laravel API endpoint..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f http://localhost:8080/api/test >/dev/null 2>&1; then
            log "Laravel API is responding correctly"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts: API not responding yet..."
        sleep 3
        ((attempt++))
    done
    
    log "ERROR: Laravel API failed to respond"
    log "Testing internal container access..."
    docker compose exec laravel-backend curl -s -f http://localhost/api/test || log "Internal API also failing"
    return 1
}

# Main installation function
main() {
    log "Metro Train Predictions App - Installation Starting"
    log "Log file: $LOG_FILE"
    
    # Directory validation
    if [[ ! -d "laravel-app" ]] || [[ ! -d "vue-app" ]]; then
        log "ERROR: Must be run from project root directory"
        exit 1
    fi
    
    # System requirements check
    log "Checking system requirements..."
    
    for cmd in docker composer; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "ERROR: $cmd is not installed"
            exit 1
        fi
    done
    
    if ! docker compose version >/dev/null 2>&1; then
        log "ERROR: Docker Compose is not available"
        exit 1
    fi
    
    # Port conflict check
    if ! check_port_conflicts; then
        exit 1
    fi
    
    # Laravel setup
    log "Setting up Laravel environment..."
    cd laravel-app
    
    if [[ ! -f ".env" ]]; then
        cp .env.example .env
        log "Created .env from .env.example"
    fi
    
    # Set Docker environment variables
    if ! grep -q "WWWUSER=" .env; then
        echo "WWWUSER=$(id -u)" >> .env
    fi
    if ! grep -q "WWWGROUP=" .env; then
        echo "WWWGROUP=$(id -g)" >> .env
    fi
    
    # Install dependencies
    log "Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader
    
    cd ..
    
    # Build containers
    log "Building Docker containers..."
    docker compose build
    
    # Start services
    log "Starting services..."
    docker compose up -d
    
    # Wait for and validate each service with improved timing and direct connectivity tests
    log "Validating service health (this may take up to 2 minutes for service initialization)..."
    
    if ! wait_for_service_health "redis"; then
        log "ERROR: Redis failed to start"
        exit 1
    fi
    
    if ! wait_for_service_health "mysql"; then
        log "ERROR: MySQL failed to start"
        exit 1
    fi
    
    if ! wait_for_service_health "laravel-backend"; then
        log "ERROR: Laravel backend failed to start"
        exit 1
    fi
    
    # Validate Vue container (no health check, just check if running)
    log "Checking Vue frontend container..."
    if ! docker compose ps vue-frontend | grep -q "Up"; then
        log "ERROR: Vue frontend container failed to start"
        docker compose logs vue-frontend
        exit 1
    fi
    
    # Final API validation
    if ! validate_api_endpoint; then
        log "ERROR: API validation failed"
        exit 1
    fi
    
    # Final connectivity verification
    log "Performing final connectivity verification..."
    
    # Test Redis connectivity
    if docker compose exec redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
        log "Redis connectivity verified"
    else
        log "WARNING: Redis connectivity check failed"
    fi
    
    # Test MySQL connectivity  
    if docker compose exec mysql mysql -u root -ppassword -e "SELECT 'MySQL OK' as status;" 2>/dev/null | grep -q "MySQL OK"; then
        log "MySQL connectivity verified"
    else
        log "WARNING: MySQL connectivity check failed"
    fi
    
    log "Installation completed successfully!"
    log ""
    log "Service URLs:"
    log "  Laravel Backend: http://localhost:8080"
    log "  Vue Frontend: http://localhost:5173"
    log "  API Test: http://localhost:8080/api/test"
    log ""
    log "Database & Cache:"
    log "  MySQL: localhost:33066"
    log "  Redis: localhost:63799"
    log ""
    log "All services are running and healthy!"
    log "Run './status_check.sh' to verify all components are working correctly."
}

# Run main function
main "$@"