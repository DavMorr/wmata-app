<?php

namespace App\Services;

use App\Models\Line;
use App\Models\Station;
use App\Models\StationAddress;
use App\Models\StationPath;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class MetroDataService
{
    public function __construct(
        private WmataApiService $wmataApi
    ) {}

    public function syncAllMetroData(): array
    {
        $results = ['lines' => 0, 'stations' => 0, 'paths' => 0, 'errors' => []];

        try {
            // Sync lines first
            $lines = $this->wmataApi->getLines();
            foreach ($lines as $lineDto) {
                Line::updateOrCreate(
                    ['line_code' => $lineDto->lineCode],
                    $lineDto->toModel()
                );
                $results['lines']++;
            }

            // Sync all stations
            $allStations = $this->wmataApi->getAllStations();
            foreach ($allStations as $stationDto) {
                Log::info('Processing station:', [
                    'code' => $stationDto->code,
                    'name' => $stationDto->name,
                    'line_codes' => [
                        'lineCode1' => $stationDto->lineCode1,
                        'lineCode2' => $stationDto->lineCode2,
                        'lineCode3' => $stationDto->lineCode3,
                        'lineCode4' => $stationDto->lineCode4,
                    ]
                ]);

                $modelData = $stationDto->toModel();
                Log::info('Station model data:', $modelData);

                $station = Station::updateOrCreate(
                    ['code' => $stationDto->code],
                    $modelData
                );

                Log::info('Station after save:', [
                    'code' => $station->code,
                    'name' => $station->name,
                    'line_codes' => [
                        'line_code_1' => $station->line_code_1,
                        'line_code_2' => $station->line_code_2,
                        'line_code_3' => $station->line_code_3,
                        'line_code_4' => $station->line_code_4,
                    ]
                ]);

                StationAddress::updateOrCreate(
                    ['station_code' => $station->code],
                    [
                        'street' => $stationDto->address->street,
                        'city' => $stationDto->address->city,
                        'state' => $stationDto->address->state,
                        'zip_code' => $stationDto->address->zip,
                    ]
                );
                $results['stations']++;
            }

            // Sync station paths for proper ordering
            $this->syncStationPaths($results);

        } catch (\Exception $e) {
            $results['errors'][] = $e->getMessage();
        }

        return $results;
    }

    private function syncStationPaths(array &$results): void
    {
        $lines = Line::all();
        
        foreach ($lines as $line) {
            try {
                $pathData = $this->wmataApi->getLineCompletePath($line->line_code);
                
                // Clear existing path data for this line
                StationPath::where('line_code', $line->line_code)->delete();
                
                // Insert new path data
                foreach ($pathData as $pathDto) {
                    StationPath::create($pathDto->toModel());
                    $results['paths']++;
                }
                
            } catch (\Exception $e) {
                $results['errors'][] = "Failed to sync path for line {$line->line_code}: " . $e->getMessage();
            }
        }
    }

    public function getOrderedStationsForLine(string $lineCode): array
    {
        $cacheKey = "metro.stations.ordered.{$lineCode}";
        
        return Cache::remember($cacheKey, 3600, function () use ($lineCode) {
            // First get all stations that serve this line (including transfer stations)
            $stations = Station::where('line_code_1', $lineCode)
                ->orWhere('line_code_2', $lineCode)
                ->orWhere('line_code_3', $lineCode)
                ->orWhere('line_code_4', $lineCode)
                ->get();

            // Get the station codes to look up in the paths table
            $stationCodes = $stations->pluck('code')->toArray();

            // Get the ordered paths for these stations
            $orderedPaths = StationPath::forLine($lineCode)
                ->whereIn('station_code', $stationCodes)
                ->ordered()
                ->get();

            if ($orderedPaths->isEmpty()) {
                Log::warning("No path data found for line {$lineCode}, using unordered stations");
                return $stations->map(function ($station) {
                    return [
                        'value' => $station->code,
                        'label' => $station->name,
                    ];
                })->toArray();
            }

            // Map the ordered paths to the response format
            return $orderedPaths->map(function ($path) {
                return [
                    'value' => $path->station_code,
                    'label' => $path->station_name,
                    'seq_num' => $path->seq_num,
                    'distance_to_prev' => $path->distance_to_prev,
                ];
            })->toArray();
        });
    }

    public function getCachedStationsForLine(string $lineCode): array
    {
        $cacheKey = "metro.stations.frontend.{$lineCode}";
        
        return Cache::remember($cacheKey, 3600, function () use ($lineCode) {
            $stationDtos = $this->wmataApi->getStationsForLine($lineCode);
            
            return array_map(function ($stationDto) {
                return [
                    'value' => $stationDto->code,
                    'label' => $stationDto->name,
                ];
            }, $stationDtos);
        });
    }

    public function getCachedLines(): array
    {
        return Cache::remember('metro.lines.frontend', 3600, function () {
            return Line::all()->map(function ($line) {
                return [
                    'value' => $line->line_code,
                    'label' => $line->display_name,
                ];
            })->toArray();
        });
    }

    public function validateCacheIntegrity(): bool
    {
        $hasLines = Cache::has('metro.lines.frontend');
        $hasStations = Cache::has('wmata.stations.all');
        
        return $hasLines && $hasStations;
    }
}