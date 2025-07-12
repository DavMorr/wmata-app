<template>
  <div class="metro-predictor">
    <h2>Metro Train Predictions</h2>

    <form @submit.prevent class="prediction-form">
      <LineSelector v-model="selectedLine" :lines="lines" @update:modelValue="onLineChange" />

      <StationSelector
        v-model="selectedStation"
        :stations="stations"
        @update:modelValue="onStationChange"
      />
    </form>

    <LoadingState :show="loading.stations">
      Loading stations for {{ getLineName(selectedLine) }} line...
    </LoadingState>

    <LoadingState :show="loading.predictions"> Loading train predictions... </LoadingState>

    <PredictionList
      :predictions="predictions"
      :station-info="stationInfo"
      :selected-station="selectedStation"
      :loading="loading.predictions"
      :last-updated="lastUpdated"
      :refresh-interval="refreshInterval"
      :get-line-name="getLineName"
    />

    <div v-if="error" class="error">
      {{ error }}
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { metroApi } from '../services/metroApi.js'
import LineSelector from './metro/form/LineSelector.vue'
import StationSelector from './metro/form/StationSelector.vue'
import PredictionList from './metro/predictions/PredictionList.vue'
import LoadingState from './metro/common/LoadingState.vue'

// Reactive state
const selectedLine = ref('')
const selectedStation = ref('')
const lines = ref([])
const stations = ref([])
const predictions = ref([])
const stationInfo = ref({})
const lastUpdated = ref('')
const error = ref('')
const refreshInterval = ref(30)

const loading = reactive({
  lines: false,
  stations: false,
  predictions: false,
})

// Auto-refresh management
let refreshTimer = null

// Computed helpers
const getLineName = (lineCode) => {
  const line = lines.value.find((l) => l.value === lineCode)
  return line ? line.label : lineCode
}

// API functions
const fetchLines = async () => {
  loading.lines = true
  error.value = ''

  try {
    const data = await metroApi.getLines()
    lines.value = data
  } catch (err) {
    error.value = `Failed to load lines: ${err.message}`
  } finally {
    loading.lines = false
  }
}

const fetchStations = async (lineCode) => {
  loading.stations = true
  error.value = ''

  try {
    const data = await metroApi.getStationsForLine(lineCode)
    stations.value = data
  } catch (err) {
    error.value = `Failed to load stations: ${err.message}`
    stations.value = []
  } finally {
    loading.stations = false
  }
}

const fetchPredictions = async (stationCode) => {
  loading.predictions = true
  error.value = ''

  try {
    const data = await metroApi.getTrainPredictions(stationCode)
    predictions.value = data.predictions
    stationInfo.value = data.station
    lastUpdated.value = data.updated_at
    refreshInterval.value = data.refresh_interval || 30
  } catch (err) {
    error.value = `Failed to load predictions: ${err.message}`
    predictions.value = []
  } finally {
    loading.predictions = false
  }
}

// Event handlers
const onLineChange = () => {
  selectedStation.value = ''
  stations.value = []
  predictions.value = []

  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }

  if (selectedLine.value && selectedLine.value !== '') {
    fetchStations(selectedLine.value)
  }
}

const onStationChange = () => {
  predictions.value = []

  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }

  if (selectedStation.value && selectedStation.value !== '') {
    fetchPredictions(selectedStation.value)

    refreshTimer = setInterval(() => {
      fetchPredictions(selectedStation.value)
    }, refreshInterval.value * 1000)
  }
}

// Lifecycle
onMounted(() => {
  fetchLines()
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})
</script>

<style scoped>
.metro-predictor {
  max-width: 800px;
  margin: 0 auto;
  padding: 1rem;
}

.metro-predictor h2 {
  text-align: center;
  margin-bottom: 2rem;
  color: var(--color-heading);
}

.prediction-form {
  background: var(--color-background-soft);
  padding: 2rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.error {
  background-color: #f8d7da;
  color: #721c24;
  padding: 1rem;
  border-radius: 6px;
  margin: 1rem 0;
  border: 1px solid #f5c6cb;
  text-align: center;
}

@media (max-width: 768px) {
  .metro-predictor {
    padding: 0.5rem;
  }

  .prediction-form {
    padding: 1rem;
  }
}
</style>
