<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MetroController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group.
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Test endpoint
Route::get('/test', function () {
    return response()->json([
        'message' => 'API is working!'
    ]);
}); 

Route::prefix('metro')->middleware(['throttle:60,1'])->group(function () {
    Route::get('lines', [MetroController::class, 'getLines']);
    Route::get('stations/{lineCode}', [MetroController::class, 'getStationsForLine']);
    Route::get('predictions/{stationCode}', [MetroController::class, 'getTrainPredictions']);
    Route::get('path/{lineCode}', [MetroController::class, 'getLinePath']); 
    // Leaving auth middleware out for now, can revisit auth setup and move to Sanctum later if necessary. 
    Route::post('sync', [MetroController::class, 'syncData']); // ->middleware('auth'); 
});
