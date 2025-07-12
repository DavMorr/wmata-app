<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MetroDataService;
use App\Services\WmataApiService;
use App\Models\Station;
use App\Models\Line;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class MetroController extends Controller
{
    public function __construct(
        private MetroDataService $metroService,
        private WmataApiService $wmataApi
    ) {}

    public function getLines(): JsonResponse
    {
        try {
            $lines = $this->metroService->getCachedLines();
            
            if (empty($lines)) {
                $this->metroService->syncAllMetroData();
                $lines = $this->metroService->getCachedLines();
            }

            return response()->json([
                'success' => true,
                'data' => $lines,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to load lines: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function getStationsForLine(string $lineCode): JsonResponse
    {
        try {
            if (!Line::where('line_code', $lineCode)->exists()) {
                return response()->json([
                    'success' => false,
                    'error' => 'Invalid line code',
                ], 400);
            }

            $stations = $this->metroService->getOrderedStationsForLine($lineCode);

            return response()->json([
                'success' => true,
                'data' => $stations,
                'meta' => [
                    'line_code' => $lineCode,
                    'total_stations' => count($stations),
                    'ordered' => true,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to load stations: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function getTrainPredictions(string $stationCode): JsonResponse
    {
        try {
            $predictions = $this->wmataApi->getTrainPredictions($stationCode);
            $station = Station::find($stationCode);

            if (!$station) {
                return response()->json([
                    'success' => false,
                    'error' => 'Station not found',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'station' => [
                        'code' => $station->code,
                        'name' => $station->name,
                    ],
                    'predictions' => array_map(
                        fn($prediction) => $prediction->toFrontend(),
                        $predictions
                    ),
                    'updated_at' => now()->toISOString(),
                    'refresh_interval' => config('wmata.frontend.predictions_refresh_interval'),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to get predictions: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function syncData(): JsonResponse
    {
        try {
            $results = $this->metroService->syncAllMetroData();

            return response()->json([
                'success' => true,
                'message' => 'All Metro data synchronized successfully',
                'results' => $results,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Sync failed: ' . $e->getMessage(),
            ], 500);
        }
    }
}