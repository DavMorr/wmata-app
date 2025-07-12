<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class LineSeeder extends Seeder
{
    /**
     * Seed the Metro lines table with WMATA line data.
     */
    public function run(): void
    {
        // Use DELETE instead of TRUNCATE to handle foreign key constraints
        DB::table('lines')->delete();

        // WMATA Metro Lines
        $lines = [
            [
                'value' => 'RD',
                'label' => 'Red Line',
                'color' => '#E51636',
                'seq_num' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'value' => 'BL',
                'label' => 'Blue Line', 
                'color' => '#0076CE',
                'seq_num' => 2,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'value' => 'YL',
                'label' => 'Yellow Line',
                'color' => '#FFD320',
                'seq_num' => 3,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'value' => 'OR',
                'label' => 'Orange Line',
                'color' => '#F7931D',
                'seq_num' => 4,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'value' => 'GR',
                'label' => 'Green Line',
                'color' => '#00B04F',
                'seq_num' => 5,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'value' => 'SV',
                'label' => 'Silver Line',
                'color' => '#919D9D',
                'seq_num' => 6,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('lines')->insert($lines);

        $this->command->info('Metro lines seeded successfully!');
    }
}
