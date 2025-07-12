<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StationAddress extends Model
{
    protected $primaryKey = 'station_code';
    public $incrementing = false;
    protected $keyType = 'string';
    
    protected $fillable = [
        'station_code', 'street', 'city', 'state', 'zip_code', 'country'
    ];

    public function station(): BelongsTo
    {
        return $this->belongsTo(Station::class, 'station_code', 'code');
    }

    public function getFormattedAttribute(): string
    {
        return "{$this->street}, {$this->city}, {$this->state} {$this->zip_code}";
    }
}