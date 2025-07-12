<?php

namespace App\DTOs;

class AddressDto
{
    public function __construct(
        public string $street,
        public string $city,
        public string $state,
        public string $zip,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            street: $data['Street'],
            city: $data['City'],
            state: $data['State'],
            zip: $data['Zip'],
        );
    }
}
