<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lines', function (Blueprint $table) {
            $table->string('line_code', 2)->primary();
            $table->string('display_name', 50);
            $table->string('start_station_code', 3);
            $table->string('end_station_code', 3);
            $table->string('internal_destination_1', 3)->nullable();
            $table->string('internal_destination_2', 3)->nullable();
            $table->timestamps();
            
            $table->index('display_name');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lines');
    }
};
