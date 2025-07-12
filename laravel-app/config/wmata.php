<?php

return [
    'api' => [
        'key' => env('WMATA_API_KEY'),
        'base_url' => env('WMATA_BASE_URL', 'https://api.wmata.com'),
        'timeout' => env('WMATA_TIMEOUT', 30),
        'retry_attempts' => env('WMATA_RETRY_ATTEMPTS', 3),
    ],
    
    'endpoints' => [
        'lines' => '/Rail.svc/json/jLines',
        'stations' => '/Rail.svc/json/jStations',
        'predictions' => '/StationPrediction.svc/json/GetPrediction',
        'path' => '/Rail.svc/json/jPath',
    ],
    
    'cache' => [
        'lines_ttl' => env('WMATA_CACHE_LINES_TTL', 86400),
        'stations_ttl' => env('WMATA_CACHE_STATIONS_TTL', 86400),
        'paths_ttl' => env('WMATA_CACHE_PATHS_TTL', 86400),
        'predictions_ttl' => env('WMATA_CACHE_PREDICTIONS_TTL', 15),
    ],
    
    'rate_limit' => [
        'max_requests_per_hour' => env('WMATA_RATE_LIMIT', 1000),
    ],
    
    'frontend' => [
        'predictions_refresh_interval' => env('WMATA_FRONTEND_REFRESH', 30),
    ],
];