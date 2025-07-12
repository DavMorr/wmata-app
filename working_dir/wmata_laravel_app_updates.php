<?php

// ============================================
// MIGRATIONS - Create database structure
// ============================================

// 2025_01_01_000001_create_lines_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLinesTable extends Migration
{
    public function up()
    {
        Schema::create('lines', function (Blueprint $table) {
            $table->string('line_code', 2)->primary();
            $table->string('display_name', 50);
            $table->string('start_station_code', 3);
            $table->string('end_station_code', 3);
            $table->string('internal_destination_1', 3)->nullable();
            $table->string('internal_destination_2', 3)->nullable();
            $table->timestamps();
            
            $table->index('display_name');
        });
    }

    public function down()
    {
        Schema::dropIfExists('lines');
    }
}

// 2025_01_01_000002_create_stations_table.php
class CreateStationsTable extends Migration
{
    public function up()
    {
        Schema::create('stations', function (Blueprint $table) {
            $table->string('code', 3)->primary();
            $table->string('name', 100);
            $table->string('station_together_1', 3)->nullable();
            $table->string('station_together_2', 3)->nullable();
            $table->string('line_code_1', 2)->nullable();
            $table->string('line_code_2', 2)->nullable();
            $table->string('line_code_3', 2)->nullable();
            $table->string('line_code_4', 2)->nullable();
            $table->decimal('lat', 10, 8);
            $table->decimal('lon', 11, 8);
            $table->timestamps();
            
            $table->index('name');
            $table->index(['line_code_1', 'line_code_2', 'line_code_3', 'line_code_4']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('stations');
    }
}

// 2025_01_01_000003_create_station_addresses_table.php
class CreateStationAddressesTable extends Migration
{
    public function up()
    {
        Schema::create('station_addresses', function (Blueprint $table) {
            $table->string('station_code', 3)->primary();
            $table->string('street', 255);
            $table->string('city', 100);
            $table->string('state', 2);
            $table->string('zip_code', 10);
            $table->string('country', 2)->default('US');
            $table->timestamps();
            
            $table->foreign('station_code')->references('code')->on('stations')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('station_addresses');
    }
}

// ============================================
// MODELS
// ============================================

// app/Models/Line.php
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Line extends Model
{
    protected $primaryKey = 'line_code';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'line_code',
        'display_name',
        'start_station_code',
        'end_station_code',
        'internal_destination_1',
        'internal_destination_2',
    ];

    public function stations(): HasMany
    {
        return $this->hasMany(Station::class, 'line_code_1', 'line_code')
                    ->orWhere('line_code_2', $this->line_code)
                    ->orWhere('line_code_3', $this->line_code)
                    ->orWhere('line_code_4', $this->line_code);
    }

    // For Vue frontend
    public function toSelectOption(): array
    {
        return [
            'value' => $this->line_code,
            'label' => $this->display_name,
        ];
    }
}

// app/Models/Station.php
class Station extends Model
{
    protected $primaryKey = 'code';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'code', 'name', 'station_together_1', 'station_together_2',
        'line_code_1', 'line_code_2', 'line_code_3', 'line_code_4',
        'lat', 'lon',
    ];

    protected function casts(): array
    {
        return [
            'lat' => 'decimal:8',
            'lon' => 'decimal:8',
        ];
    }

    public function address()
    {
        return $this->hasOne(StationAddress::class, 'station_code', 'code');
    }

    public function getLineCodes(): array
    {
        return array_filter([
            $this->line_code_1,
            $this->line_code_2,
            $this->line_code_3,
            $this->line_code_4,
        ]);
    }

    public function isOnLine(string $lineCode): bool
    {
        return in_array($lineCode, $this->getLineCodes());
    }

    // For Vue frontend
    public function toSelectOption(): array
    {
        return [
            'value' => $this->code,
            'label' => $this->name,
        ];
    }

    public function scopeOnLine($query, string $lineCode)
    {
        return $query->where(function ($q) use ($lineCode) {
            $q->where('line_code_1', $lineCode)
              ->orWhere('line_code_2', $lineCode)
              ->orWhere('line_code_3', $lineCode)
              ->orWhere('line_code_4', $lineCode);
        });
    }
}

// app/Models/StationAddress.php
class StationAddress extends Model
{
    protected $primaryKey = 'station_code';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'station_code', 'street', 'city', 'state', 'zip_code', 'country'
    ];

    public function station()
    {
        return $this->belongsTo(Station::class, 'station_code', 'code');
    }
}

// ============================================
// DTOs (Data Transfer Objects)
// ============================================

// app/DTOs/LineDto.php
class LineDto
{
    public function __construct(
        public string $displayName,
        public string $lineCode,
        public string $startStationCode,
        public string $endStationCode,
        public ?string $internalDestination1 = null,
        public ?string $internalDestination2 = null,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            displayName: $data['DisplayName'],
            lineCode: $data['LineCode'],
            startStationCode: $data['StartStationCode'],
            endStationCode: $data['EndStationCode'],
            internalDestination1: !empty($data['InternalDestination1']) ? $data['InternalDestination1'] : null,
            internalDestination2: !empty($data['InternalDestination2']) ? $data['InternalDestination2'] : null,
        );
    }

    public function toModel(): array
    {
        return [
            'line_code' => $this->lineCode,
            'display_name' => $this->displayName,
            'start_station_code' => $this->startStationCode,
            'end_station_code' => $this->endStationCode,
            'internal_destination_1' => $this->internalDestination1,
            'internal_destination_2' => $this->internalDestination2,
        ];
    }
}

// app/DTOs/StationDto.php
class StationDto
{
    public function __construct(
        public string $code,
        public string $name,
        public ?string $stationTogether1,
        public ?string $stationTogether2,
        public ?string $lineCode1,
        public ?string $lineCode2,
        public ?string $lineCode3,
        public ?string $lineCode4,
        public float $lat,
        public float $lon,
        public AddressDto $address,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            code: $data['code'],
            name: $data['name'],
            stationTogether1: !empty($data['stationTogether1']) ? $data['stationTogether1'] : null,
            stationTogether2: !empty($data['stationTogether2']) ? $data['stationTogether2'] : null,
            lineCode1: $data['lineCode1'] ?? null,
            lineCode2: $data['lineCode2'] ?? null,
            lineCode3: $data['lineCode3'] ?? null,
            lineCode4: $data['lineCode4'] ?? null,
            lat: (float) $data['lat'],
            lon: (float) $data['lon'],
            address: AddressDto::fromArray($data['address']),
        );
    }

    public function toModel(): array
    {
        return [
            'code' => $this->code,
            'name' => $this->name,
            'station_together_1' => $this->stationTogether1,
            'station_together_2' => $this->stationTogether2,
            'line_code_1' => $this->lineCode1,
            'line_code_2' => $this->lineCode2,
            'line_code_3' => $this->lineCode3,
            'line_code_4' => $this->lineCode4,
            'lat' => $this->lat,
            'lon' => $this->lon,
        ];
    }
}

// app/DTOs/AddressDto.php
class AddressDto
{
    public function __construct(
        public string $street,
        public string $city,
        public string $state,
        public string $zip,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            street: $data['Street'],
            city: $data['City'],
            state: $data['State'],
            zip: $data['Zip'],
        );
    }
}

// app/DTOs/TrainPredictionDto.php
class TrainPredictionDto
{
    public function __construct(
        public string $car,
        public string $destination,
        public ?string $destinationCode,
        public string $destinationName,
        public string $group,
        public string $line,
        public string $locationCode,
        public string $locationName,
        public string $min,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            car: $data['Car'],
            destination: $data['Destination'],
            destinationCode: $data['DestinationCode'],
            destinationName: $data['DestinationName'],
            group: $data['Group'],
            line: $data['Line'],
            locationCode: $data['LocationCode'],
            locationName: $data['LocationName'],
            min: $data['Min'],
        );
    }

    public function toFrontend(): array
    {
        return [
            'line' => $this->line,
            'destination' => $this->destinationName,
            'minutes' => $this->min,
            'cars' => $this->car,
            'group' => $this->group,
        ];
    }
}

// ============================================
// SERVICES
// ============================================

// app/Services/WmataApiService.php
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class WmataApiService
{
    private const RATE_LIMIT_KEY = 'wmata_api_rate_limit';
    private const MAX_REQUESTS_PER_HOUR = 1000; // Adjust based on your API limits

    public function __construct(
        private string $apiKey,
        private string $baseUrl = 'https://api.wmata.com'
    ) {}

    public function getLines(): array
    {
        $response = $this->makeRequest('/Rail.svc/json/jLines');
        
        return array_map(
            fn($line) => LineDto::fromArray($line),
            $response['Lines'] ?? []
        );
    }

    public function getStations(): array
    {
        $response = $this->makeRequest('/Rail.svc/json/jStations');
        
        return array_map(
            fn($station) => StationDto::fromArray($station),
            $response['Stations'] ?? []
        );
    }

    public function getTrainPredictions(string $stationCode): array
    {
        $cacheKey = "train_predictions_{$stationCode}";
        
        // Check cache first (1 minute cache for real-time data)
        return Cache::remember($cacheKey, 60, function () use ($stationCode) {
            $response = $this->makeRequest("/StationPrediction.svc/json/GetPrediction/{$stationCode}");
            
            return array_map(
                fn($train) => TrainPredictionDto::fromArray($train),
                $response['Trains'] ?? []
            );
        });
    }

    private function makeRequest(string $endpoint): array
    {
        // Rate limiting check
        if (!$this->checkRateLimit()) {
            throw new \Exception('API rate limit exceeded. Please try again later.');
        }

        try {
            $response = Http::withHeaders([
                'api_key' => $this->apiKey,
                'Accept' => 'application/json',
            ])
            ->timeout(30)
            ->retry(3, 1000, function ($exception) {
                return $exception instanceof \Illuminate\Http\Client\ConnectionException;
            })
            ->get($this->baseUrl . $endpoint);

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
        return $currentCount < self::MAX_REQUESTS_PER_HOUR;
    }

    private function incrementRateLimit(): void
    {
        $currentCount = Cache::get(self::RATE_LIMIT_KEY, 0);
        Cache::put(self::RATE_LIMIT_KEY, $currentCount + 1, 3600); // 1 hour
    }
}

// app/Services/MetroDataService.php
class MetroDataService
{
    public function __construct(
        private WmataApiService $wmataApi
    ) {}

    public function syncLinesAndStations(): array
    {
        $results = ['lines' => 0, 'stations' => 0, 'errors' => []];

        try {
            // Sync lines
            $lines = $this->wmataApi->getLines();
            foreach ($lines as $lineDto) {
                Line::updateOrCreate(
                    ['line_code' => $lineDto->lineCode],
                    $lineDto->toModel()
                );
                $results['lines']++;
            }

            // Cache lines for frontend
            Cache::forever('metro.lines', $lines);

            // Sync stations
            $stations = $this->wmataApi->getStations();
            foreach ($stations as $stationDto) {
                $station = Station::updateOrCreate(
                    ['code' => $stationDto->code],
                    $stationDto->toModel()
                );

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

            // Cache stations for frontend
            Cache::forever('metro.stations', $stations);

        } catch (\Exception $e) {
            $results['errors'][] = $e->getMessage();
        }

        return $results;
    }

    public function getCachedLines(): array
    {
        return Cache::rememberForever('metro.lines.frontend', function () {
            return Line::all()->map->toSelectOption()->toArray();
        });
    }

    public function getCachedStationsForLine(string $lineCode): array
    {
        $cacheKey = "metro.stations.line.{$lineCode}";
        
        return Cache::rememberForever($cacheKey, function () use ($lineCode) {
            return Station::onLine($lineCode)
                          ->orderBy('name')
                          ->get()
                          ->map->toSelectOption()
                          ->toArray();
        });
    }

    public function validateCacheIntegrity(): bool
    {
        $hasLines = Cache::has('metro.lines.frontend');
        $hasStations = Cache::has('metro.stations');
        
        return $hasLines && $hasStations;
    }
}

// ============================================
// API CONTROLLERS
// ============================================

// app/Http/Controllers/Api/MetroController.php
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
                // If cache is empty, sync data
                $this->metroService->syncLinesAndStations();
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
            $stations = $this->metroService->getCachedStationsForLine($lineCode);

            return response()->json([
                'success' => true,
                'data' => $stations,
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
            $results = $this->metroService->syncLinesAndStations();

            return response()->json([
                'success' => true,
                'message' => 'Data synchronized successfully',
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

// ============================================
// ROUTES
// ============================================

// routes/api.php
use App\Http\Controllers\Api\MetroController;

Route::prefix('metro')->group(function () {
    Route::get('lines', [MetroController::class, 'getLines']);
    Route::get('stations/{lineCode}', [MetroController::class, 'getStationsForLine']);
    Route::get('predictions/{stationCode}', [MetroController::class, 'getTrainPredictions']);
    Route::post('sync', [MetroController::class, 'syncData']);
});

// ============================================
// CONSOLE COMMANDS
// ============================================

// app/Console/Commands/SyncMetroData.php
use Illuminate\Console\Command;

class SyncMetroData extends Command
{
    protected $signature = 'metro:sync {--validate : Validate cache integrity first}';
    protected $description = 'Sync Metro lines and stations data from WMATA API';

    public function __construct(
        private MetroDataService $metroService
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        if ($this->option('validate')) {
            $this->info('🔍 Checking cache integrity...');
            
            if ($this->metroService->validateCacheIntegrity()) {
                $this->info('✅ Cache is valid');
                return Command::SUCCESS;
            } else {
                $this->warn('⚠️ Cache validation failed, proceeding with sync...');
            }
        }

        $this->info('🚇 Starting Metro data synchronization...');

        try {
            $results = $this->metroService->syncLinesAndStations();

            $this->table(
                ['Type', 'Count'],
                [
                    ['Lines synced', $results['lines']],
                    ['Stations synced', $results['stations']],
                ]
            );

            if (!empty($results['errors'])) {
                $this->error('⚠️ Errors encountered:');
                foreach ($results['errors'] as $error) {
                    $this->line("  • {$error}");
                }
                return Command::FAILURE;
            }

            $this->info('✅ Metro data sync completed successfully!');
            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error("❌ Sync failed: {$e->getMessage()}");
            return Command::FAILURE;
        }
    }
}

// ============================================
// SCHEDULED TASKS
// ============================================

// app/Console/Kernel.php
class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule $schedule)
    {
        // Validate cache integrity every hour
        $schedule->command('metro:sync --validate')
                 ->hourly()
                 ->description('Validate Metro cache integrity');

        // Full sync once daily at 3 AM
        $schedule->command('metro:sync')
                 ->dailyAt('03:00')
                 ->description('Daily Metro data sync');
    }
}

// ============================================
// VUE 3 FRONTEND COMPONENT
// ============================================

/*
<!-- resources/js/components/MetroTrainPredictor.vue -->
<template>
  <div class="metro-predictor">
    <h2>Metro Train Predictions</h2>
    
    <form @submit.prevent class="prediction-form">
      <!-- Line Selection -->
      <div class="form-group">
        <label for="line">Line:</label>
        <select 
          id="line" 
          v-model="selectedLine" 
          @change="onLineChange"
          required
        >
          <option value="" disabled>Select a line</option>
          <option 
            v-for="line in lines" 
            :key="line.value" 
            :value="line.value"
          >
            {{ line.label }}
          </option>
        </select>
      </div>

      <!-- Station Selection -->
      <div class="form-group" v-if="selectedLine && stations.length > 0">
        <label for="station">Station:</label>
        <select 
          id="station" 
          v-model="selectedStation" 
          @change="onStationChange"
          required
        >
          <option value="" disabled>Select a station</option>
          <option 
            v-for="station in stations" 
            :key="station.value" 
            :value="station.value"
          >
            {{ station.label }}
          </option>
        </select>
      </div>
    </form>

    <!-- Loading States -->
    <div v-if="loading.stations" class="loading">
      Loading stations...
    </div>
    <div v-if="loading.predictions" class="loading">
      Loading train predictions...
    </div>

    <!-- Train Predictions -->
    <div v-if="predictions && predictions.length > 0" class="predictions">
      <h3>
        Train arrival times for: {{ stationInfo.name }} ({{ stationInfo.code }})
      </h3>
      <ul class="prediction-list">
        <li 
          v-for="(prediction, index) in predictions" 
          :key="index"
          class="prediction-item"
        >
          <span class="line-name">{{ getLineName(prediction.line) }} line</span>
          to {{ prediction.destination }}: 
          <span class="arrival-time" :class="getArrivalClass(prediction.minutes)">
            {{ formatArrivalTime(prediction.minutes) }}
          </span>
          <span class="car-count">({{ prediction.cars }} cars)</span>
        </li>
      </ul>
      <div class="last-updated">
        Last updated: {{ lastUpdated }}
      </div>
    </div>

    <!-- No Predictions -->
    <div v-else-if="selectedStation && !loading.predictions" class="no-predictions">
      No train predictions available for this station.
    </div>

    <!-- Error Messages -->
    <div v-if="error" class="error">
      {{ error }}
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'

// Reactive state
const selectedLine = ref('')
const selectedStation = ref('')
const lines = ref([])
const stations = ref([])
const predictions = ref([])
const stationInfo = ref({})
const lastUpdated = ref('')
const error = ref('')

const loading = reactive({
  lines: false,
  stations: false,
  predictions: false
})

// Computed helpers
const getLineName = (lineCode) => {
  const line = lines.value.find(l => l.value === lineCode)
  return line ? line.label : lineCode
}

const formatArrivalTime = (minutes) => {
  if (minutes === 'BRD') return 'Boarding'
  if (minutes === 'ARR') return 'Arriving'
  return `${minutes} min${minutes !== '1' ? 's' : ''}`
}

const getArrivalClass = (minutes) => {
  if (minutes === 'BRD' || minutes === 'ARR') return 'arriving'
  const num = parseInt(minutes)
  if (num <= 2) return 'soon'
  if (num <= 5) return 'moderate'
  return 'later'
}

// API functions
const fetchLines = async () => {
  loading.lines = true
  error.value = ''
  
  try {
    const response = await fetch('/api/metro/lines')
    const data = await response.json()
    
    if (data.success) {
      lines.value = data.data
    } else {
      throw new Error(data.error)
    }
  } catch (err) {
    error.value = `Failed to load lines: ${err.message}`
  } finally {
    loading.lines = false
  }
}

const fetchStations = async (lineCode) => {
  loading.stations = true
  error.value = ''
  
  try {
    const response = await fetch(`/api/metro/stations/${lineCode}`)
    const data = await response.json()
    
    if (data.success) {
      stations.value = data.data
    } else {
      throw new Error(data.error)
    }
  } catch (err) {
    error.value = `Failed to load stations: ${err.message}`
    stations.value = []
  } finally {
    loading.stations = false
  }
}

const fetchPredictions = async (stationCode) => {
  loading.predictions = true
  error.value = ''
  
  try {
    const response = await fetch(`/api/metro/predictions/${stationCode}`)
    const data = await response.json()
    
    if (data.success) {
      predictions.value = data.data.predictions
      stationInfo.value = data.data.station
      lastUpdated.value = new Date(data.data.updated_at).toLocaleTimeString()
    } else {
      throw new Error(data.error)
    }
  } catch (err) {
    error.value = `Failed to load predictions: ${err.message}`
    predictions.value = []
  } finally {
    loading.predictions = false
  }
}

// Event handlers
const onLineChange = () => {
  selectedStation.value = ''
  stations.value = []
  predictions.value = []
  
  if (selectedLine.value) {
    fetchStations(selectedLine.value)
  }
}

const onStationChange = () => {
  predictions.value = []
  
  if (selectedStation.value) {
    fetchPredictions(selectedStation.value)
  }
}

// Auto-refresh predictions every minute
let refreshInterval = null

watch(selectedStation, (newStation, oldStation) => {
  // Clear existing interval
  if (refreshInterval) {
    clearInterval(refreshInterval)
    refreshInterval = null
  }
  
  // Start new interval if station is selected
  if (newStation) {
    refreshInterval = setInterval(() => {
      fetchPredictions(newStation)
    }, 60000) // Refresh every minute
  }
})

// Lifecycle
onMounted(() => {
  fetchLines()
})

// Cleanup
onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
})
</script>

<style scoped>
.metro-predictor {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.prediction-form {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #333;
}

.form-group select {
  width: 100%;
  padding: 12px;
  border: 2px solid #ddd;
  border-radius: 6px;
  font-size: 16px;
  background: white;
  transition: border-color 0.3s;
}

.form-group select:focus {
  outline: none;
  border-color: #0056b3;
}

.loading {
  text-align: center;
  padding: 20px;
  color: #666;
  font-style: italic;
}

.predictions {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 20px;
  margin-top: 20px;
}

.predictions h3 {
  margin-top: 0;
  color: #333;
  border-bottom: 2px solid #0056b3;
  padding-bottom: 10px;
}

.prediction-list {
  list-style: none;
  padding: 0;
  margin: 20px 0;
}

.prediction-item {
  display: flex;
  align-items: center;
  padding: 12px;
  border-bottom: 1px solid #eee;
  transition: background-color 0.2s;
}

.prediction-item:hover {
  background-color: #f8f9fa;
}

.prediction-item:last-child {
  border-bottom: none;
}

.line-name {
  font-weight: 600;
  margin-right: 8px;
}

.arrival-time {
  font-weight: bold;
  margin: 0 8px;
  padding: 4px 8px;
  border-radius: 4px;
}

.arrival-time.arriving {
  background-color: #dc3545;
  color: white;
}

.arrival-time.soon {
  background-color: #fd7e14;
  color: white;
}

.arrival-time.moderate {
  background-color: #ffc107;
  color: #333;
}

.arrival-time.later {
  background-color: #28a745;
  color: white;
}

.car-count {
  color: #666;
  font-size: 0.9em;
  margin-left: auto;
}

.last-updated {
  text-align: center;
  color: #666;
  font-size: 0.9em;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #eee;
}

.no-predictions {
  text-align: center;
  padding: 40px;
  color: #666;
  font-style: italic;
  background: #f8f9fa;
  border-radius: 8px;
  margin-top: 20px;
}

.error {
  background-color: #f8d7da;
  color: #721c24;
  padding: 12px;
  border-radius: 6px;
  margin: 16px 0;
  border: 1px solid #f5c6cb;
}

/* Responsive design */
@media (max-width: 768px) {
  .metro-predictor {
    padding: 10px;
  }
  
  .prediction-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .car-count {
    margin-left: 0;
  }
}
</style>
*/

// ============================================
// LARAVEL 12 CONFIGURATION FILES
// ============================================

// config/wmata.php
<?php

return [
    'api_key' => env('WMATA_API_KEY'),
    'base_url' => env('WMATA_BASE_URL', 'https://api.wmata.com'),
    'rate_limit' => [
        'max_requests_per_hour' => env('WMATA_RATE_LIMIT', 1000),
        'cache_predictions_seconds' => env('WMATA_CACHE_PREDICTIONS', 60),
    ],
    'timeout' => env('WMATA_TIMEOUT', 30),
    'retry_attempts' => env('WMATA_RETRY_ATTEMPTS', 3),
];

// ============================================
// SERVICE PROVIDER
// ============================================

// app/Providers/WmataServiceProvider.php
use Illuminate\Support\ServiceProvider;

class WmataServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(WmataApiService::class, function ($app) {
            return new WmataApiService(
                apiKey: config('wmata.api_key'),
                baseUrl: config('wmata.base_url')
            );
        });

        $this->app->singleton(MetroDataService::class, function ($app) {
            return new MetroDataService(
                $app->make(WmataApiService::class)
            );
        });
    }

    public function boot(): void
    {
        $this->publishes([
            __DIR__.'/../../config/wmata.php' => config_path('wmata.php'),
        ], 'wmata-config');
    }
}

// ============================================
// ENVIRONMENT CONFIGURATION
// ============================================

// .env additions
/*
# WMATA API Configuration
WMATA_API_KEY=your_wmata_api_key_here
WMATA_BASE_URL=https://api.wmata.com
WMATA_RATE_LIMIT=1000
WMATA_CACHE_PREDICTIONS=60
WMATA_TIMEOUT=30
WMATA_RETRY_ATTEMPTS=3
*/

// ============================================
// MAIN VUE APP INTEGRATION
// ============================================

// resources/js/app.js
import { createApp } from 'vue'
import MetroTrainPredictor from './components/MetroTrainPredictor.vue'

const app = createApp({})

app.component('MetroTrainPredictor', MetroTrainPredictor)

app.mount('#app')

// ============================================
// BLADE TEMPLATE
// ============================================

// resources/views/metro.blade.php
/*
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Metro Train Predictions</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <div id="app">
        <div class="container">
            <metro-train-predictor></metro-train-predictor>
        </div>
    </div>
</body>
</html>
*/

// ============================================
// WEB ROUTES
// ============================================

// routes/web.php
Route::get('/metro', function () {
    return view('metro');
})->name('metro');

// ============================================
// MIDDLEWARE FOR API RATE LIMITING
// ============================================

// app/Http/Middleware/WmataRateLimit.php
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class WmataRateLimit
{
    public function handle(Request $request, Closure $next)
    {
        $key = 'wmata_api_rate_limit_' . $request->ip();
        $maxRequests = 60; // Per minute for frontend requests
        
        $requests = Cache::get($key, 0);
        
        if ($requests >= $maxRequests) {
            return response()->json([
                'success' => false,
                'error' => 'Rate limit exceeded. Please try again later.',
            ], 429);
        }
        
        Cache::put($key, $requests + 1, 60);
        
        return $next($request);
    }
}

// Apply middleware to API routes in routes/api.php
Route::prefix('metro')->middleware(['throttle:60,1', WmataRateLimit::class])->group(function () {
    Route::get('lines', [MetroController::class, 'getLines']);
    Route::get('stations/{lineCode}', [MetroController::class, 'getStationsForLine']);
    Route::get('predictions/{stationCode}', [MetroController::class, 'getTrainPredictions']);
    Route::post('sync', [MetroController::class, 'syncData'])->middleware('auth'); // Protect sync endpoint
});

// ============================================
// TESTING EXAMPLES
// ============================================

// tests/Feature/MetroApiTest.php
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MetroApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_get_lines()
    {
        // Seed test data
        Line::factory()->create([
            'line_code' => 'RD',
            'display_name' => 'Red',
        ]);

        $response = $this->get('/api/metro/lines');

        $response->assertOk()
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         '*' => ['value', 'label']
                     ]
                 ]);
    }

    public function test_can_get_stations_for_line()
    {
        Line::factory()->create(['line_code' => 'RD']);
        Station::factory()->create([
            'code' => 'A01',
            'name' => 'Metro Center',
            'line_code_1' => 'RD',
        ]);

        $response = $this->get('/api/metro/stations/RD');

        $response->assertOk()
                 ->assertJsonFragment([
                     'value' => 'A01',
                     'label' => 'Metro Center'
                 ]);
    }

    public function test_handles_rate_limiting()
    {
        // Make too many requests
        for ($i = 0; $i < 65; $i++) {
            $response = $this->get('/api/metro/lines');
        }

        $response->assertStatus(429)
                 ->assertJsonFragment([
                     'error' => 'Rate limit exceeded. Please try again later.'
                 ]);
    }
}

// ============================================
// MODEL FACTORIES FOR TESTING
// ============================================

// database/factories/LineFactory.php
use Illuminate\Database\Eloquent\Factories\Factory;

class LineFactory extends Factory
{
    protected $model = Line::class;

    public function definition(): array
    {
        return [
            'line_code' => $this->faker->randomElement(['RD', 'BL', 'GR', 'OR', 'SV', 'YL']),
            'display_name' => $this->faker->randomElement(['Red', 'Blue', 'Green', 'Orange', 'Silver', 'Yellow']),
            'start_station_code' => $this->faker->regexify('[A-Z][0-9]{2}'),
            'end_station_code' => $this->faker->regexify('[A-Z][0-9]{2}'),
        ];
    }
}

// database/factories/StationFactory.php
class StationFactory extends Factory
{
    protected $model = Station::class;

    public function definition(): array
    {
        return [
            'code' => $this->faker->unique()->regexify('[A-Z][0-9]{2}'),
            'name' => $this->faker->city . ' Station',
            'line_code_1' => $this->faker->randomElement(['RD', 'BL', 'GR', 'OR', 'SV', 'YL']),
            'lat' => $this->faker->latitude(38.8, 39.0),
            'lon' => $this->faker->longitude(-77.5, -76.9),
        ];
    }
}

// ============================================
// PACKAGE.JSON DEPENDENCIES
// ============================================

/*
{
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.0.0",
    "laravel-vite-plugin": "^1.0.0",
    "vite": "^5.0.0",
    "vue": "^3.4.0"
  }
}
*/

// ============================================
// VITE CONFIG
// ============================================

// vite.config.js
/*
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
        vue(),
    ],
});
*/