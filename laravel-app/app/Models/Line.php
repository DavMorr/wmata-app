<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Line extends Model
{
    protected $primaryKey = 'line_code';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'line_code',
        'display_name',
        'start_station_code',
        'end_station_code',
        'internal_destination_1',
        'internal_destination_2',
    ];

    public function startStation(): BelongsTo
    {
        return $this->belongsTo(Station::class, 'start_station_code', 'code');
    }

    public function endStation(): BelongsTo
    {
        return $this->belongsTo(Station::class, 'end_station_code', 'code');
    }

    public function stationPaths(): HasMany
    {
        return $this->hasMany(StationPath::class, 'line_code', 'line_code')->orderBy('seq_num');
    }

    public function toSelectOption(): array
    {
        return [
            'value' => $this->line_code,
            'label' => $this->display_name,
        ];
    }
}