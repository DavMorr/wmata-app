<?php

namespace App\Providers;

use App\Services\WmataApiService;
use App\Services\MetroDataService;
use Illuminate\Support\ServiceProvider;

class WmataServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(WmataApiService::class, function ($app) {
            $config = config('wmata');
            
            return new WmataApiService(
                apiKey: $config['api']['key'],
                baseUrl: $config['api']['base_url'],
                endpoints: $config['endpoints'],
                cacheConfig: $config['cache'],
                maxRequestsPerHour: $config['rate_limit']['max_requests_per_hour']
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
