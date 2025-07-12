<?php

namespace Database\Factories;

use App\Models\Line;
use Illuminate\Database\Eloquent\Factories\Factory;

class LineFactory extends Factory
{
    protected $model = Line::class;

    public function definition(): array
    {
        $lineColors = [
            'RD' => 'Red',
            'BL' => 'Blue',
            'YL' => 'Yellow',
            'GR' => 'Green',
            'OR' => 'Orange',
            'SV' => 'Silver'
        ];

        $lineCode = $this->faker->randomElement(array_keys($lineColors));

        return [
            'line_code' => $lineCode,
            'display_name' => $lineColors[$lineCode],
            'start_station_code' => $this->faker->regexify('[A-Z][0-9]{2}'),
            'end_station_code' => $this->faker->regexify('[A-Z][0-9]{2}'),
            'internal_destination_1' => $this->faker->optional()->regexify('[A-Z][0-9]{2}'),
            'internal_destination_2' => $this->faker->optional()->regexify('[A-Z][0-9]{2}'),
        ];
    }
} 