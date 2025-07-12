<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('station_addresses', function (Blueprint $table) {
            $table->string('station_code', 3)->primary();
            $table->string('street', 255);
            $table->string('city', 100);
            $table->string('state', 2);
            $table->string('zip_code', 10);
            $table->string('country', 2)->default('US');
            $table->timestamps();
            
            $table->foreign('station_code')->references('code')->on('stations')->onDelete('cascade');
            $table->index(['city', 'state']);
            $table->index('zip_code');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('station_addresses');
    }
};
