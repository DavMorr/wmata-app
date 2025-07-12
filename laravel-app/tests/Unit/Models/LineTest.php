<?php

namespace Tests\Unit\Models;

use Tests\TestCase;
use App\Models\Line;
use App\Models\Station;
use Illuminate\Foundation\Testing\RefreshDatabase;

class LineTest extends TestCase
{
    use RefreshDatabase;

    public function test_line_model_has_correct_primary_key(): void
    {
        $line = new Line();
        $this->assertEquals('line_code', $line->getKeyName());
        $this->assertFalse($line->incrementing);
        $this->assertEquals('string', $line->getKeyType());
    }

    public function test_line_model_has_correct_fillable_attributes(): void
    {
        $line = new Line();
        $expectedFillable = [
            'line_code',
            'display_name',
            'start_station_code',
            'end_station_code',
            'internal_destination_1',
            'internal_destination_2'
        ];
        
        $this->assertEquals($expectedFillable, $line->getFillable());
    }

    public function test_line_belongs_to_start_station()
    {
        $startStation = Station::factory()->create(['code' => 'A01']);
        $endStation = Station::factory()->create(['code' => 'B01']);
        
        $line = Line::factory()->create([
            'start_station_code' => 'A01',
            'end_station_code' => 'B01',
        ]);

        $this->assertInstanceOf(Station::class, $line->startStation);
        $this->assertEquals('A01', $line->startStation->code);
    }

    public function test_line_belongs_to_end_station()
    {
        $startStation = Station::factory()->create(['code' => 'A01']);
        $endStation = Station::factory()->create(['code' => 'B01']);
        
        $line = Line::factory()->create([
            'start_station_code' => 'A01',
            'end_station_code' => 'B01',
        ]);

        $this->assertInstanceOf(Station::class, $line->endStation);
        $this->assertEquals('B01', $line->endStation->code);
    }

    public function test_to_select_option_returns_correct_format()
    {
        $line = Line::factory()->create([
            'line_code' => 'RD',
            'display_name' => 'Red',
        ]);

        $expected = [
            'value' => 'RD',
            'label' => 'Red',
        ];

        $this->assertEquals($expected, $line->toSelectOption());
    }
}
