<?php

namespace App\Console\Commands;

use App\Services\WmataApiService;
use Illuminate\Console\Command;

class TestWmataConnection extends Command
{
    protected $signature = 'metro:test-connection';
    protected $description = 'Test the connection to the WMATA API';

    public function __construct(
        private WmataApiService $wmataApi
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        $this->info('Testing WMATA API connection...');

        try {
            // Try to fetch lines as a simple connectivity test
            $lines = $this->wmataApi->getLines();
            
            $this->info('✓ Successfully connected to WMATA API');
            $this->info('Found ' . count($lines) . ' metro lines');
            
            // Display rate limit information
            $rateLimit = cache()->get('wmata_api_rate_limit', 0);
            $maxRequests = config('wmata.rate_limit.max_requests_per_hour', 1000);
            $this->info("Rate limit status: {$rateLimit}/{$maxRequests} requests this hour");

            return Command::SUCCESS;
        } catch (\Exception $e) {
            $this->error('✗ Failed to connect to WMATA API');
            $this->error('Error: ' . $e->getMessage());
            
            return Command::FAILURE;
        }
    }
} 