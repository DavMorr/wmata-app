<?php

// ============================================
// COMPLETE COMMAND TESTS
// ============================================

// tests/Feature/SyncMetroDataCommandTest.php
namespace Tests\Feature;

use App\Models\Line;
use App\Models\Station;
use App\Models\StationAddress;
use App\Models\StationPath;
use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class SyncMetroDataCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_sync_command_runs_successfully()
    {
        // Mock all WMATA API endpoints
        Http::fake([
            'https://api.wmata.com/Rail.svc/json/jLines' => Http::response([
                'Lines' => [
                    [
                        'DisplayName' => 'Red',
                        'LineCode' => 'RD',
                        'StartStationCode' => 'A01',
                        'EndStationCode' => 'B01',
                        'InternalDestination1' => '',
                        'InternalDestination2' => '',
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jStations' => Http::response([
                'Stations' => [
                    [
                        'code' => 'A01',
                        'name' => 'Metro Center',
                        'stationTogether1' => '',
                        'stationTogether2' => '',
                        'lineCode1' => 'RD',
                        'lineCode2' => null,
                        'lineCode3' => null,
                        'lineCode4' => null,
                        'lat' => 38.898303,
                        'lon' => -77.028099,
                        'address' => [
                            'Street' => '607 13th St. NW',
                            'City' => 'Washington',
                            'State' => 'DC',
                            'Zip' => '20005'
                        ]
                    ],
                    [
                        'code' => 'B01',
                        'name' => 'Union Station',
                        'stationTogether1' => '',
                        'stationTogether2' => '',
                        'lineCode1' => 'RD',
                        'lineCode2' => null,
                        'lineCode3' => null,
                        'lineCode4' => null,
                        'lat' => 38.897545,
                        'lon' => -77.006787,
                        'address' => [
                            'Street' => '50 Massachusetts Ave NE',
                            'City' => 'Washington',
                            'State' => 'DC',
                            'Zip' => '20002'
                        ]
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jPath*' => Http::response([
                'Path' => [
                    [
                        'LineCode' => 'RD',
                        'StationCode' => 'A01',
                        'StationName' => 'Metro Center',
                        'SeqNum' => 1,
                        'DistanceToPrev' => 0
                    ],
                    [
                        'LineCode' => 'RD',
                        'StationCode' => 'B01',
                        'StationName' => 'Union Station',
                        'SeqNum' => 2,
                        'DistanceToPrev' => 2500
                    ]
                ]
            ])
        ]);

        $this->artisan('metro:sync')
             ->expectsOutput('🚇 Starting Metro data synchronization...')
             ->expectsOutput('✅ Metro data sync completed successfully!')
             ->assertExitCode(0);

        // Verify lines were created
        $this->assertDatabaseHas('lines', [
            'line_code' => 'RD',
            'display_name' => 'Red',
            'start_station_code' => 'A01',
            'end_station_code' => 'B01'
        ]);

        // Verify stations were created
        $this->assertDatabaseHas('stations', [
            'code' => 'A01',
            'name' => 'Metro Center',
            'line_code_1' => 'RD'
        ]);

        $this->assertDatabaseHas('stations', [
            'code' => 'B01',
            'name' => 'Union Station',
            'line_code_1' => 'RD'
        ]);

        // Verify addresses were created
        $this->assertDatabaseHas('station_addresses', [
            'station_code' => 'A01',
            'street' => '607 13th St. NW',
            'city' => 'Washington',
            'state' => 'DC',
            'zip_code' => '20005'
        ]);

        // Verify station paths were created
        $this->assertDatabaseHas('station_paths', [
            'line_code' => 'RD',
            'station_code' => 'A01',
            'station_name' => 'Metro Center',
            'seq_num' => 1,
            'distance_to_prev' => 0
        ]);

        $this->assertDatabaseHas('station_paths', [
            'line_code' => 'RD',
            'station_code' => 'B01',
            'station_name' => 'Union Station',
            'seq_num' => 2,
            'distance_to_prev' => 2500
        ]);

        // Verify we have correct counts
        $this->assertEquals(1, Line::count());
        $this->assertEquals(2, Station::count());
        $this->assertEquals(2, StationAddress::count());
        $this->assertEquals(2, StationPath::count());
    }

    public function test_sync_command_with_validate_flag()
    {
        // First, populate cache with some data
        Cache::put('metro.lines.frontend', [
            ['value' => 'RD', 'label' => 'Red']
        ]);
        Cache::put('wmata.stations.all', []);

        $this->artisan('metro:sync --validate')
             ->expectsOutput('🔍 Checking cache integrity...')
             ->expectsOutput('✅ Cache is valid')
             ->assertExitCode(0);
    }

    public function test_sync_command_with_invalid_cache()
    {
        // Clear cache to simulate invalid state
        Cache::flush();

        $this->artisan('metro:sync --validate')
             ->expectsOutput('🔍 Checking cache integrity...')
             ->expectsOutput('⚠️ Cache validation failed, proceeding with sync...')
             ->assertExitCode(1); // Should fail validation
    }

    public function test_sync_command_handles_api_failures()
    {
        Http::fake([
            'https://api.wmata.com/*' => Http::response([], 500)
        ]);

        $this->artisan('metro:sync')
             ->expectsOutput('🚇 Starting Metro data synchronization...')
             ->expectsOutput('❌ Sync failed:')
             ->assertExitCode(1);

        // Verify no data was created due to failure
        $this->assertEquals(0, Line::count());
        $this->assertEquals(0, Station::count());
    }

    public function test_sync_command_handles_network_timeout()
    {
        Http::fake([
            'https://api.wmata.com/*' => function () {
                throw new \Illuminate\Http\Client\ConnectionException('Connection timeout');
            }
        ]);

        $this->artisan('metro:sync')
             ->expectsOutput('🚇 Starting Metro data synchronization...')
             ->expectsOutput('❌ Sync failed:')
             ->assertExitCode(1);
    }

    public function test_sync_command_handles_partial_failures()
    {
        Http::fake([
            // Lines succeed
            'https://api.wmata.com/Rail.svc/json/jLines' => Http::response([
                'Lines' => [
                    [
                        'DisplayName' => 'Red',
                        'LineCode' => 'RD',
                        'StartStationCode' => 'A01',
                        'EndStationCode' => 'B01',
                        'InternalDestination1' => '',
                        'InternalDestination2' => '',
                    ]
                ]
            ]),
            // Stations fail
            'https://api.wmata.com/Rail.svc/json/jStations' => Http::response([], 500),
            // Paths fail
            'https://api.wmata.com/Rail.svc/json/jPath*' => Http::response([], 500)
        ]);

        $this->artisan('metro:sync')
             ->expectsOutput('🚇 Starting Metro data synchronization...')
             ->expectsOutput('⚠️ Errors encountered:')
             ->assertExitCode(1);

        // Verify lines were created but stations weren't
        $this->assertEquals(1, Line::count());
        $this->assertEquals(0, Station::count());
    }

    public function test_sync_command_updates_existing_data()
    {
        // Create existing data
        Line::factory()->create([
            'line_code' => 'RD',
            'display_name' => 'Old Red Name',
        ]);

        Station::factory()->create([
            'code' => 'A01',
            'name' => 'Old Station Name',
        ]);

        // Mock API with updated data
        Http::fake([
            'https://api.wmata.com/Rail.svc/json/jLines' => Http::response([
                'Lines' => [
                    [
                        'DisplayName' => 'Red Line Updated',
                        'LineCode' => 'RD',
                        'StartStationCode' => 'A01',
                        'EndStationCode' => 'B01',
                        'InternalDestination1' => '',
                        'InternalDestination2' => '',
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jStations' => Http::response([
                'Stations' => [
                    [
                        'code' => 'A01',
                        'name' => 'Metro Center Updated',
                        'stationTogether1' => '',
                        'stationTogether2' => '',
                        'lineCode1' => 'RD',
                        'lineCode2' => null,
                        'lineCode3' => null,
                        'lineCode4' => null,
                        'lat' => 38.898303,
                        'lon' => -77.028099,
                        'address' => [
                            'Street' => '607 13th St. NW',
                            'City' => 'Washington',
                            'State' => 'DC',
                            'Zip' => '20005'
                        ]
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jPath*' => Http::response([
                'Path' => [
                    [
                        'LineCode' => 'RD',
                        'StationCode' => 'A01',
                        'StationName' => 'Metro Center Updated',
                        'SeqNum' => 1,
                        'DistanceToPrev' => 0
                    ]
                ]
            ])
        ]);

        $this->artisan('metro:sync')
             ->assertExitCode(0);

        // Verify data was updated, not duplicated
        $this->assertEquals(1, Line::count());
        $this->assertEquals(1, Station::count());

        // Verify updates took effect
        $this->assertDatabaseHas('lines', [
            'line_code' => 'RD',
            'display_name' => 'Red Line Updated',
        ]);

        $this->assertDatabaseHas('stations', [
            'code' => 'A01',
            'name' => 'Metro Center Updated',
        ]);
    }

    public function test_sync_command_clears_old_path_data()
    {
        // Create a line and old path data
        $line = Line::factory()->create(['line_code' => 'RD']);
        
        StationPath::factory()->create([
            'line_code' => 'RD',
            'station_code' => 'OLD1',
            'seq_num' => 1
        ]);
        
        StationPath::factory()->create([
            'line_code' => 'RD',
            'station_code' => 'OLD2',
            'seq_num' => 2
        ]);

        // Mock API with new path data
        Http::fake([
            'https://api.wmata.com/Rail.svc/json/jLines' => Http::response([
                'Lines' => [
                    [
                        'DisplayName' => 'Red',
                        'LineCode' => 'RD',
                        'StartStationCode' => 'A01',
                        'EndStationCode' => 'B01',
                        'InternalDestination1' => '',
                        'InternalDestination2' => '',
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jStations' => Http::response([
                'Stations' => [
                    [
                        'code' => 'A01',
                        'name' => 'Metro Center',
                        'stationTogether1' => '',
                        'stationTogether2' => '',
                        'lineCode1' => 'RD',
                        'lineCode2' => null,
                        'lineCode3' => null,
                        'lineCode4' => null,
                        'lat' => 38.898303,
                        'lon' => -77.028099,
                        'address' => [
                            'Street' => '607 13th St. NW',
                            'City' => 'Washington',
                            'State' => 'DC',
                            'Zip' => '20005'
                        ]
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jPath*' => Http::response([
                'Path' => [
                    [
                        'LineCode' => 'RD',
                        'StationCode' => 'A01',
                        'StationName' => 'Metro Center',
                        'SeqNum' => 1,
                        'DistanceToPrev' => 0
                    ]
                ]
            ])
        ]);

        $this->artisan('metro:sync')
             ->assertExitCode(0);

        // Verify old path data was cleared and new data added
        $this->assertEquals(1, StationPath::count());
        $this->assertDatabaseMissing('station_paths', ['station_code' => 'OLD1']);
        $this->assertDatabaseMissing('station_paths', ['station_code' => 'OLD2']);
        $this->assertDatabaseHas('station_paths', ['station_code' => 'A01']);
    }

    public function test_sync_command_shows_progress_table()
    {
        Http::fake([
            'https://api.wmata.com/Rail.svc/json/jLines' => Http::response([
                'Lines' => [
                    [
                        'DisplayName' => 'Red',
                        'LineCode' => 'RD',
                        'StartStationCode' => 'A01',
                        'EndStationCode' => 'B01',
                        'InternalDestination1' => '',
                        'InternalDestination2' => '',
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jStations' => Http::response([
                'Stations' => [
                    [
                        'code' => 'A01',
                        'name' => 'Metro Center',
                        'stationTogether1' => '',
                        'stationTogether2' => '',
                        'lineCode1' => 'RD',
                        'lineCode2' => null,
                        'lineCode3' => null,
                        'lineCode4' => null,
                        'lat' => 38.898303,
                        'lon' => -77.028099,
                        'address' => [
                            'Street' => '607 13th St. NW',
                            'City' => 'Washington',
                            'State' => 'DC',
                            'Zip' => '20005'
                        ]
                    ]
                ]
            ]),
            'https://api.wmata.com/Rail.svc/json/jPath*' => Http::response([
                'Path' => [
                    [
                        'LineCode' => 'RD',
                        'StationCode' => 'A01',
                        'StationName' => 'Metro Center',
                        'SeqNum' => 1,
                        'DistanceToPrev' => 0
                    ]
                ]
            ])
        ]);

        $this->artisan('metro:sync')
             ->expectsTable(['Type', 'Count'], [
                 ['Lines synced', 1],
                 ['Stations synced', 1],
                 ['Path entries synced', 1],
             ])
             ->assertExitCode(0);
    }

    public function test_sync_command_with_verbose_output()
    {
        Http::fake([
            'https://api.wmata.com/*' => Http::response(['Lines' => [], 'Stations' => [], 'Path' => []])
        ]);

        $this->artisan('metro:sync', ['--verbose' => true])
             ->expectsOutput('🚇 Starting Metro data synchronization...')
             ->expectsOutput('✅ Metro data sync completed successfully!')
             ->expectsOutput('📍 Stations will now display in proper sequence order')
             ->assertExitCode(0);
    }
}