<?php

namespace App\Services;

use App\DTOs\LineDto;
use App\DTOs\StationDto;
use App\DTOs\TrainPredictionDto;
use App\DTOs\StationPathDto;
use App\Models\Line;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class WmataApiService
{
    private const RATE_LIMIT_KEY = 'wmata_api_rate_limit';

    public function __construct(
        private string $apiKey,
        private string $baseUrl,
        private array $endpoints,
        private array $cacheConfig,
        private int $maxRequestsPerHour
    ) {}

    public function getLines(): array
    {
        $cacheKey = 'wmata.lines';
        
        return Cache::remember($cacheKey, $this->cacheConfig['lines_ttl'], function () {
            $response = $this->makeRequest($this->endpoints['lines']);
            
            return array_map(
                fn($line) => LineDto::fromArray($line),
                $response['Lines'] ?? []
            );
        });
    }

    public function getStationsForLine(string $lineCode): array
    {
        $cacheKey = "wmata.stations.line.{$lineCode}";
        
        return Cache::remember($cacheKey, $this->cacheConfig['stations_ttl'], function () use ($lineCode) {
            $endpoint = $this->endpoints['stations'] . "?LineCode={$lineCode}";
            $response = $this->makeRequest($endpoint);
            
            return array_map(
                fn($station) => StationDto::fromArray($station),
                $response['Stations'] ?? []
            );
        });
    }

    public function getAllStations(): array
    {
        $cacheKey = 'wmata.stations.all';
        
        return Cache::remember($cacheKey, $this->cacheConfig['stations_ttl'], function () {
            // Get the base stations list first
            $response = $this->makeRequest($this->endpoints['stations']);
            $allStations = [];
            $seenStations = [];

            // Process base station list
            foreach ($response['Stations'] ?? [] as $stationData) {
                $station = StationDto::fromArray($stationData);
                $allStations[] = $station;
                $seenStations[$station->code] = true;

                // If this station has a "together" station and we haven't seen it yet,
                // we'll need to fetch its data when processing lines
                if ($station->stationTogether1) {
                    $seenStations[$station->stationTogether1] = false;
                }
                if ($station->stationTogether2) {
                    $seenStations[$station->stationTogether2] = false;
                }
            }

            // Now get stations for each line to ensure we have all variations
            $lines = $this->getLines();
            foreach ($lines as $line) {
                $lineStations = $this->getStationsForLine($line->lineCode);
                foreach ($lineStations as $station) {
                    if (!isset($seenStations[$station->code]) || $seenStations[$station->code] === false) {
                        $allStations[] = $station;
                        $seenStations[$station->code] = true;
                    }
                }
            }

            return $allStations;
        });
    }

    public function getTrainPredictions(string $stationCode): array
    {
        $singleStationCode = $this->extractFirstStationCode($stationCode);
        $cacheKey = "wmata.predictions.{$singleStationCode}";
        
        return Cache::remember($cacheKey, $this->cacheConfig['predictions_ttl'], function () use ($singleStationCode) {
            $endpoint = $this->endpoints['predictions'] . "/{$singleStationCode}";
            $response = $this->makeRequest($endpoint);
            
            return array_map(
                fn($train) => TrainPredictionDto::fromArray($train),
                $response['Trains'] ?? []
            );
        });
    }

    public function getStationPath(string $fromStationCode, string $toStationCode): array
    {
        $cacheKey = "wmata.path.{$fromStationCode}.{$toStationCode}";
        
        return Cache::remember($cacheKey, $this->cacheConfig['paths_ttl'], function () use ($fromStationCode, $toStationCode) {
            $endpoint = $this->endpoints['path'] . "?FromStationCode={$fromStationCode}&ToStationCode={$toStationCode}";
            $response = $this->makeRequest($endpoint);
            
            return array_map(
                fn($pathItem) => StationPathDto::fromArray($pathItem),
                $response['Path'] ?? []
            );
        });
    }

    public function getLineCompletePath(string $lineCode): array
    {
        // Get the line data to find start and end stations
        $lines = $this->getLines();
        $line = collect($lines)->firstWhere('lineCode', $lineCode);
        
        if (!$line) {
            throw new \Exception("Line {$lineCode} not found");
        }
        
        if (empty($line->startStationCode) || empty($line->endStationCode)) {
            throw new \Exception("Line {$lineCode} missing start or end station codes");
        }
        
        // Use the jPath endpoint to get the correct geographical order
        $cacheKey = "wmata.path.complete.{$lineCode}";
        
        return Cache::remember($cacheKey, $this->cacheConfig['paths_ttl'], function () use ($line, $lineCode) {
            Log::info("Getting complete path for line {$lineCode}", [
                'start_station' => $line->startStationCode,
                'end_station' => $line->endStationCode
            ]);
            
            // Get the path from start to end station using WMATA jPath API
            $pathData = $this->getStationPath($line->startStationCode, $line->endStationCode);
            
            // Ensure each path item has the correct line code
            foreach ($pathData as $pathItem) {
                $pathItem->lineCode = $lineCode;
            }
            
            return $pathData;
        });
    }

    private function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): int
    {
        // Convert coordinates to radians
        $lat1 = deg2rad($lat1);
        $lon1 = deg2rad($lon1);
        $lat2 = deg2rad($lat2);
        $lon2 = deg2rad($lon2);

        // Haversine formula
        $dlat = $lat2 - $lat1;
        $dlon = $lon2 - $lon1;
        $a = sin($dlat/2) * sin($dlat/2) + cos($lat1) * cos($lat2) * sin($dlon/2) * sin($dlon/2);
        $c = 2 * atan2(sqrt($a), sqrt(1-$a));
        
        // Earth's radius in meters
        $r = 6371000;
        
        // Calculate distance in meters and round to integer
        return (int) round($r * $c);
    }

    private function extractFirstStationCode(string $stationCodes): string
    {
        $codes = explode(',', $stationCodes);
        return trim($codes[0]);
    }

    private function makeRequest(string $endpoint): array
    {
        if (!$this->checkRateLimit()) {
            throw new \Exception('API rate limit exceeded. Please try again later.');
        }

        try {
            $url = $this->baseUrl . $endpoint;
            
            Log::info('WMATA API Request', ['url' => $url]);

            $response = Http::withHeaders([
                'api_key' => $this->apiKey,
                'Accept' => 'application/json',
            ])
            ->timeout(30)
            ->retry(3, 1000, function ($exception) {
                return $exception instanceof \Illuminate\Http\Client\ConnectionException;
            })
            ->get($url);

            if ($response->failed()) {
                Log::error('WMATA API request failed', [
                    'endpoint' => $endpoint,
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
                
                throw new \Exception("API request failed with status: {$response->status()}");
            }

            $this->incrementRateLimit();
            return $response->json();

        } catch (\Exception $e) {
            Log::error('WMATA API error', [
                'endpoint' => $endpoint,
                'error' => $e->getMessage(),
            ]);
            
            throw $e;
        }
    }

    private function checkRateLimit(): bool
    {
        $currentCount = Cache::get(self::RATE_LIMIT_KEY, 0);
        return $currentCount < $this->maxRequestsPerHour;
    }

    private function incrementRateLimit(): void
    {
        $currentCount = Cache::get(self::RATE_LIMIT_KEY, 0);
        Cache::put(self::RATE_LIMIT_KEY, $currentCount + 1, 3600);
    }
}