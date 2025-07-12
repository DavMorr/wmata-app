import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    watch: {
      usePolling: true, // Better for Docker on some systems
    },
    hmr: {
      // Hot Module Replacement configuration for Docker
      host: 'localhost',
      port: 5173,
    },
  },
  // Define environment variables for production builds
  define: {
    __VUE_PROD_DEVTOOLS__: false,
  },
})