<?php

namespace App\Console\Commands;

use App\Services\MetroDataService;
use Illuminate\Console\Command;

class SyncMetroData extends Command
{
    protected $signature = 'metro:sync 
                           {--validate : Validate cache integrity first}';
    protected $description = 'Sync Metro data from WMATA API including station paths';

    public function __construct(
        private MetroDataService $metroService
    ) {
        parent::__construct();
    }

    public function handle(): int
    {
        if ($this->option('validate')) {
            $this->info('Checking cache integrity...');
            
            if ($this->metroService->validateCacheIntegrity()) {
                $this->info('Cache is valid');
                return Command::SUCCESS;
            } else {
                $this->warn('Cache validation failed, proceeding with sync...');
            }
        }

        $this->info('Starting Metro data synchronization...');

        try {
            $results = $this->metroService->syncAllMetroData();

            $this->table(
                ['Type', 'Count'],
                [
                    ['Lines synced', $results['lines']],
                    ['Stations synced', $results['stations']],
                    ['Path entries synced', $results['paths']],
                ]
            );

            if (!empty($results['errors'])) {
                $this->error('Errors encountered:');
                foreach ($results['errors'] as $error) {
                    $this->line("  • {$error}");
                }
                return Command::FAILURE;
            }

            $this->info('Metro data sync completed successfully!');
            $this->info('Stations will now display in proper sequence order');
            
            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error("Sync failed: {$e->getMessage()}");
            return Command::FAILURE;
        }
    }
}
