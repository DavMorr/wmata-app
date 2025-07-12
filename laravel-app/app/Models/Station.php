<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Station extends Model
{
    protected $primaryKey = 'code';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'code', 'name', 
        'line_code_1', 'line_code_2', 'line_code_3', 'line_code_4',
        'station_together_1', 'station_together_2', 
        'lat', 'lon', 
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'lat' => 'decimal:8',
            'lon' => 'decimal:8',
            'is_active' => 'boolean',
        ];
    }

    public function address(): HasOne
    {
        return $this->hasOne(StationAddress::class, 'station_code', 'code');
    }

    public function getLineCodes(): array
    {
        return array_filter([
            $this->line_code_1,
            $this->line_code_2,
            $this->line_code_3,
            $this->line_code_4,
        ]);
    }

    protected function coordinates(): Attribute
    {
        return Attribute::make(
            get: fn() => [
                'lat' => (float) $this->lat,
                'lng' => (float) $this->lon,
            ]
        );
    }

    public function scopeOnLine($query, string $lineCode)
    {
        return $query->where(function ($q) use ($lineCode) {
            $q->where('line_code_1', $lineCode)
              ->orWhere('line_code_2', $lineCode)
              ->orWhere('line_code_3', $lineCode)
              ->orWhere('line_code_4', $lineCode);
        });
    }

    public function toSelectOption(): array
    {
        return [
            'value' => $this->code,
            'label' => $this->name,
        ];
    }
}