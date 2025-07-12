<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StationPath extends Model
{
    protected $fillable = [
        'line_code', 'station_code', 'station_name', 'seq_num', 'distance_to_prev',
    ];

    protected function casts(): array
    {
        return [
            'seq_num' => 'integer',
            'distance_to_prev' => 'integer',
        ];
    }

    public function line(): BelongsTo
    {
        return $this->belongsTo(Line::class, 'line_code', 'line_code');
    }

    public function station(): BelongsTo
    {
        return $this->belongsTo(Station::class, 'station_code', 'code');
    }

    public function scopeForLine($query, string $lineCode)
    {
        return $query->where('line_code', $lineCode);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('seq_num');
    }
}