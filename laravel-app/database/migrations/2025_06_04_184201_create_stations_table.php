<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stations', function (Blueprint $table) {
            $table->string('code', 3)->primary();
            $table->string('name', 100);
            $table->string('line_code_1', 2)->nullable();
            $table->string('line_code_2', 2)->nullable();
            $table->string('line_code_3', 2)->nullable();
            $table->string('line_code_4', 2)->nullable();
            $table->string('station_together_1', 3)->nullable();
            $table->string('station_together_2', 3)->nullable();
            $table->decimal('lat', 10, 8);
            $table->decimal('lon', 11, 8);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('name');
            $table->index(['lat', 'lon']);
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stations');
    }
};
