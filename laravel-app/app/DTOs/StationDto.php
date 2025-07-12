<?php

namespace App\DTOs;

class StationDto
{
    public function __construct(
        public string $code,
        public string $name,
        public ?string $stationTogether1,
        public ?string $stationTogether2,
        public ?string $lineCode1,
        public ?string $lineCode2,
        public ?string $lineCode3,
        public ?string $lineCode4,
        public float $lat,
        public float $lon,
        public AddressDto $address,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            code: $data['Code'] ?? $data['StationCode'] ?? $data['code'],
            name: $data['Name'] ?? $data['name'],
            stationTogether1: !empty($data['StationTogether1']) ? $data['StationTogether1'] : (!empty($data['stationTogether1']) ? $data['stationTogether1'] : null),
            stationTogether2: !empty($data['StationTogether2']) ? $data['StationTogether2'] : (!empty($data['stationTogether2']) ? $data['stationTogether2'] : null),
            lineCode1: $data['LineCode1'] ?? $data['lineCode1'] ?? null,
            lineCode2: $data['LineCode2'] ?? $data['lineCode2'] ?? null,
            lineCode3: $data['LineCode3'] ?? $data['lineCode3'] ?? null,
            lineCode4: $data['LineCode4'] ?? $data['lineCode4'] ?? null,
            lat: (float) ($data['Lat'] ?? $data['lat']),
            lon: (float) ($data['Lon'] ?? $data['lon']),
            address: AddressDto::fromArray($data['Address'] ?? $data['address']),
        );
    }

    public function toModel(): array
    {
        return [
            'code' => $this->code,
            'name' => $this->name,
            'station_together_1' => $this->stationTogether1,
            'station_together_2' => $this->stationTogether2,
            'line_code_1' => $this->lineCode1,
            'line_code_2' => $this->lineCode2,
            'line_code_3' => $this->lineCode3,
            'line_code_4' => $this->lineCode4,
            'lat' => $this->lat,
            'lon' => $this->lon,
        ];
    }
}