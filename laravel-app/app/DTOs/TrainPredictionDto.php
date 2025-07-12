<?php

namespace App\DTOs;

class TrainPredictionDto
{
    public function __construct(
        public ?string $car, 
        public string $destination,
        public ?string $destinationCode, 
        public string $destinationName,
        public ?string $group,  
        public string $line,
        public string $locationCode,
        public string $locationName,
        public string $min,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            car: $data['Car'] ?? null,  
            destination: $data['Destination'],
            destinationCode: $data['DestinationCode'] ?? null,
            destinationName: $data['DestinationName'],
            group: $data['Group'] ?? null,  
            line: $data['Line'],
            locationCode: $data['LocationCode'],
            locationName: $data['LocationName'],
            min: $data['Min'],
        );
    }

    public function toFrontend(): array
    {
        return [
            'line' => $this->line,
            'destination' => $this->destinationName,
            'minutes' => $this->min,
            'cars' => $this->car ?? 'Unknown',
            'group' => $this->group ?? '1',              
        ];
    }
}