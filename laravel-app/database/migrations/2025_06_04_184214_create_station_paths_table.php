<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('station_paths', function (Blueprint $table) {
            $table->id();
            $table->string('line_code', 2);
            $table->string('station_code', 3);
            $table->string('station_name', 100);
            $table->integer('seq_num');
            $table->integer('distance_to_prev')->default(0);
            $table->timestamps();
            
            $table->index(['line_code', 'seq_num']);
            $table->index('station_code');
            $table->unique(['line_code', 'station_code']);
            
            $table->foreign('line_code')->references('line_code')->on('lines');
            $table->foreign('station_code')->references('code')->on('stations');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('station_paths');
    }
};
