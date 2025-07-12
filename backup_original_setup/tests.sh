# Method 1: Check .env file directly
docker compose exec laravel-backend cat .env | grep WMATA_API_KEY

# Method 2: Use Laravel's framework (artisan tinker)
docker compose exec laravel-backend php artisan tinker
# Then in tinker: config('wmata.api_key') or env('WMATA_API_KEY')



# Test Laravel's Metro endpoints
curl -v http://localhost:8080/api/metro/lines
curl -v http://localhost:8080/api/metro/stations/RD  
curl -v http://localhost:8080/api/metro/predictions/A01



# Check current CORS config
docker compose exec laravel-backend cat config/cors.php



# Check Vue's API configuration
cat vue-app/src/api/index.js
cat vue-app/.env




# Test CORS from Vue's perspective (simulate browser request)
curl -H "Origin: http://localhost:5173" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS \
     http://localhost:8080/api/metro/lines




docker compose exec laravel-backend cat .env | grep WMATA_API_KEY
curl http://localhost:8080/api/metro/lines















