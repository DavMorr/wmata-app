<?php

namespace App\DTOs;

class StationPathDto
{
    public function __construct(
        public string $lineCode,
        public string $stationCode,
        public string $stationName,
        public int $seqNum,
        public int $distanceToPrev,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            lineCode: $data['LineCode'],
            stationCode: $data['StationCode'],
            stationName: $data['StationName'],
            seqNum: (int) $data['SeqNum'],
            distanceToPrev: (int) $data['DistanceToPrev'],
        );
    }

    public function toModel(): array
    {
        return [
            'line_code' => $this->lineCode,
            'station_code' => $this->stationCode,
            'station_name' => $this->stationName,
            'seq_num' => $this->seqNum,
            'distance_to_prev' => $this->distanceToPrev,
        ];
    }
}