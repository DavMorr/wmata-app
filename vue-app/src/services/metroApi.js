import axios from 'axios'

// Use your existing axios instance
import api from '../api/index.js'

class MetroApiService {
  async makeRequest(endpoint) {
    try {
      const response = await api.get(endpoint)

      if (!response.data.success) {
        throw new Error(response.data.error || 'API request failed')
      }

      return response.data.data
    } catch (error) {
      console.error('Metro API Error:', error)
      throw error
    }
  }

  async getLines() {
    return this.makeRequest('/metro/lines')
  }

  async getStationsForLine(lineCode) {
    return this.makeRequest(`/metro/stations/${lineCode}`)
  }

  async getTrainPredictions(stationCode) {
    try {
      const response = await api.get(`/metro/predictions/${stationCode}`)

      if (!response.data.success) {
        throw new Error(response.data.error || 'API request failed')
      }

      return response.data.data
    } catch (error) {
      console.error('Metro API Error:', error)
      throw error
    }
  }
}

export const metroApi = new MetroApiService()
