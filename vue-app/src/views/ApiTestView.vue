<script setup>
import ApiTest from '../components/ApiTest.vue'
</script>

<template>
  <div class="api-test">
    <h1>API Test</h1>
    <div>
      <ApiTest />
    </div>
  </div>
</template>

<style scoped>
.api-test {
  padding: 20px;
  max-width: 600px;
  margin: 0 auto;
  text-align: center;
}
.api-test > h1,
.api-test > div {
  display: block;
}

@media (min-width: 1024px) {
  .api-test {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
  .api-test > h1,
  .api-test > div {
    display: block !important;
  }
}
</style>
