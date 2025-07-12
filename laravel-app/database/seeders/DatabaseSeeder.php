<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Artisan;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Metro Train Prediction App uses a custom sync command
        // that pulls data directly from the WMATA API
        try {
            $this->command->info('Syncing Metro data from WMATA API...');
            
            $exitCode = Artisan::call('metro:sync');
            
            if ($exitCode === 0) {
                $this->command->info('Metro data sync completed successfully');
            } else {
                $this->command->error('Metro data sync failed with exit code: ' . $exitCode);
                throw new \Exception('Metro sync command failed');
            }
            
        } catch (\Exception $e) {
            $this->command->error('Failed to sync Metro data: ' . $e->getMessage());
            $this->command->warn('Falling back to manual line seeding...');
            
            // Fallback: Use manual line seeder
            try {
                $this->call(LineSeeder::class);
                $this->command->info('Manual line seeding completed successfully');
            } catch (\Exception $seedError) {
                $this->command->error('Manual seeding also failed: ' . $seedError->getMessage());
                $this->command->warn('Run "php artisan db:seed --class=LineSeeder" manually');
            }
        }
    }
}
