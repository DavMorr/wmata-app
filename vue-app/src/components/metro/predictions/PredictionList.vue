<template>
  <div v-if="predictions.length > 0" class="predictions">
    <h3>Train arrival times for: {{ stationInfo.name }} ({{ stationInfo.code }})</h3>
    <ul class="prediction-list">
      <li v-for="(prediction, index) in predictions" :key="index" class="prediction-item">
        <span class="line-name">{{ getLineName(prediction.line) }} line</span>
        <span class="destination">to {{ prediction.destination }}</span>
        <span class="arrival-time" :class="getArrivalClass(prediction.minutes)">
          {{ formatArrivalTime(prediction.minutes) }}
        </span>
        <span class="car-count">({{ prediction.cars }} cars)</span>
      </li>
    </ul>
    <div class="last-updated">
      Last updated: {{ formatLastUpdated }}
      <span v-if="refreshInterval" class="refresh-info">
        (refreshes every {{ refreshInterval }}s)
      </span>
    </div>
  </div>
  <div v-else-if="selectedStation && !loading" class="no-predictions">
    No train predictions available for this station.
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  predictions: {
    type: Array,
    required: true,
    default: () => [],
  },
  stationInfo: {
    type: Object,
    required: true,
    default: () => ({}),
  },
  selectedStation: {
    type: String,
    required: true,
  },
  loading: {
    type: Boolean,
    default: false,
  },
  lastUpdated: {
    type: String,
    required: true,
  },
  refreshInterval: {
    type: Number,
    default: 30,
  },
  getLineName: {
    type: Function,
    required: true,
  },
})

const formatLastUpdated = computed(() => {
  try {
    const date = new Date(props.lastUpdated)
    if (isNaN(date.getTime())) {
      return 'Updating...'
    }
    return date.toLocaleTimeString(undefined, {
      hour: 'numeric',
      minute: '2-digit',
      second: '2-digit',
      hour12: true,
    })
  } catch (e) {
    return 'Updating...'
  }
})

const formatArrivalTime = (minutes) => {
  if (minutes === 'BRD') return 'Boarding'
  if (minutes === 'ARR') return 'Arriving'
  return `${minutes} min${minutes !== '1' ? 's' : ''}`
}

const getArrivalClass = (minutes) => {
  if (minutes === 'BRD' || minutes === 'ARR') return 'arriving'
  const num = parseInt(minutes)
  if (num <= 2) return 'soon'
  if (num <= 5) return 'moderate'
  return 'later'
}
</script>

<style scoped>
.predictions {
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 2rem;
  margin-top: 2rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.predictions h3 {
  margin-top: 0;
  color: var(--color-heading);
  text-align: center;
  padding-bottom: 1rem;
  border-bottom: 2px solid var(--color-border);
  margin-bottom: 1.5rem;
}

.prediction-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.prediction-item {
  display: grid;
  grid-template-columns: minmax(120px, 150px) 1fr minmax(100px, auto) minmax(80px, auto);
  gap: 1rem;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid var(--color-border);
  transition: background-color 0.2s;
}

.prediction-item:last-child {
  border-bottom: none;
}

.prediction-item:hover {
  background-color: var(--color-background-soft);
}

.line-name {
  font-weight: 600;
  white-space: nowrap;
}

.destination {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.arrival-time {
  font-weight: bold;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  text-align: center;
  white-space: nowrap;
  justify-self: end;
}

.arrival-time.arriving {
  background-color: #dc3545;
  color: white;
}

.arrival-time.soon {
  background-color: #fd7e14;
  color: white;
}

.arrival-time.moderate {
  background-color: #ffc107;
  color: #333;
}

.arrival-time.later {
  background-color: #28a745;
  color: white;
}

.car-count {
  color: var(--color-text);
  font-size: 0.9em;
  text-align: right;
  white-space: nowrap;
}

.last-updated {
  text-align: center;
  color: var(--color-text);
  font-size: 0.9em;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border);
}

.refresh-info {
  color: var(--color-text);
  opacity: 0.7;
}

.no-predictions {
  text-align: center;
  padding: 3rem 1rem;
  color: var(--color-text);
  font-style: italic;
  background: var(--color-background-soft);
  border-radius: 8px;
  margin-top: 2rem;
}

@media (max-width: 768px) {
  .predictions {
    padding: 1rem;
  }

  .prediction-item {
    grid-template-columns: 1fr;
    gap: 0.75rem;
    text-align: center;
    padding: 1.5rem 1rem;
  }

  .line-name,
  .destination,
  .arrival-time,
  .car-count {
    justify-self: center;
    text-align: center;
  }

  .destination {
    max-width: 90%;
    margin: 0 auto;
  }

  .arrival-time {
    min-width: 120px;
  }
}
</style>
