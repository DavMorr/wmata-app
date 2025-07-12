<?php

namespace Database\Factories;

use App\Models\Station;
use Illuminate\Database\Eloquent\Factories\Factory;

class StationFactory extends Factory
{
    protected $model = Station::class;

    public function definition(): array
    {
        return [
            'code' => $this->faker->unique()->regexify('[A-Z][0-9]{2}'),
            'name' => $this->faker->unique()->words(3, true),
            'line_code_1' => $this->faker->randomElement(['RD', 'BL', 'YL', 'GR', 'OR', 'SV']),
            'line_code_2' => $this->faker->optional()->randomElement(['RD', 'BL', 'YL', 'GR', 'OR', 'SV']),
            'line_code_3' => $this->faker->optional()->randomElement(['RD', 'BL', 'YL', 'GR', 'OR', 'SV']),
            'line_code_4' => $this->faker->optional()->randomElement(['RD', 'BL', 'YL', 'GR', 'OR', 'SV']),
            'station_together_1' => $this->faker->optional()->regexify('[A-Z][0-9]{2}'),
            'station_together_2' => $this->faker->optional()->regexify('[A-Z][0-9]{2}'),
            'lat' => $this->faker->latitude(38.8, 39.0),
            'lon' => $this->faker->longitude(-77.1, -76.9),
            'is_active' => true,
        ];
    }
} 