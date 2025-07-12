<?php

namespace App\DTOs;

class LineDto
{
    public function __construct(
        public string $displayName,
        public string $lineCode,
        public string $startStationCode,
        public string $endStationCode,
        public ?string $internalDestination1 = null,
        public ?string $internalDestination2 = null,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            displayName: $data['DisplayName'],
            lineCode: $data['LineCode'],
            startStationCode: $data['StartStationCode'],
            endStationCode: $data['EndStationCode'],
            internalDestination1: !empty($data['InternalDestination1']) ? $data['InternalDestination1'] : null,
            internalDestination2: !empty($data['InternalDestination2']) ? $data['InternalDestination2'] : null,
        );
    }

    public function toModel(): array
    {
        return [
            'line_code' => $this->lineCode,
            'display_name' => $this->displayName,
            'start_station_code' => $this->startStationCode,
            'end_station_code' => $this->endStationCode,
            'internal_destination_1' => $this->internalDestination1,
            'internal_destination_2' => $this->internalDestination2,
        ];
    }
}