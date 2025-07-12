<template>
  <div class="api-test">
    <div>
      <button @click="testApi" :disabled="loading">
        {{ loading ? 'Testing...' : 'Test API Connection' }}
      </button>
      <div v-if="message" :class="{ success: !error, error: error }">
        {{ message }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import api from '@/api'

const loading = ref(false)
const message = ref('')
const error = ref(false)

const testApi = async () => {
  loading.value = true
  message.value = ''
  error.value = false

  try {
    const response = await api.get('/test')
    message.value = response.data.message
  } catch (err) {
    error.value = true
    message.value = 'Error connecting to API: ' + (err.response?.data?.message || err.message)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.api-test {
  padding: 20px;
  max-width: 400px;
  margin: 0 auto;
}

button {
  padding: 10px 20px;
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.success {
  color: #4caf50;
  margin-top: 10px;
}

.error {
  color: #f44336;
  margin-top: 10px;
}
</style>
