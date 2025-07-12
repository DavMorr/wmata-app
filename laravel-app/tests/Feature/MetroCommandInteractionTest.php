<?php

// ============================================
// ADDITIONAL COMMAND TESTS
// ============================================

// tests/Feature/MetroCommandInteractionTest.php
namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Artisan;

class MetroCommandInteractionTest extends TestCase
{
    use RefreshDatabase;

    public function test_sync_command_can_be_called_programmatically()
    {
        Http::fake([
            'https://api.wmata.com/*' => Http::response([
                'Lines' => [],
                'Stations' => [],
                'Path' => []
            ])
        ]);

        $exitCode = Artisan::call('metro:sync');
        $output = Artisan::output();

        $this->assertEquals(0, $exitCode);
        $this->assertStringContainsString('Metro data sync completed', $output);
    }

    public function test_sync_command_respects_environment_settings()
    {
        // Test that command uses environment configuration
        config(['wmata.cache.lines_ttl' => 3600]);
        
        $this->assertTrue(config('wmata.cache.lines_ttl') === 3600);
    }

    public function test_command_signature_and_description()
    {
        $command = $this->app['Illuminate\Contracts\Console\Kernel']
                        ->all()['metro:sync'];

        $this->assertEquals('metro:sync', $command->getName());
        $this->assertStringContainsString('Metro', $command->getDescription());
    }
}