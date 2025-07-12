<template>
  <div v-if="show" class="loading">
    <slot>Loading...</slot>
  </div>
</template>

<script setup>
defineProps({
  show: {
    type: Boolean,
    default: false,
  },
})
</script>

<style scoped>
.loading {
  text-align: center;
  padding: 1rem;
  color: var(--color-text);
  font-style: italic;
  background: var(--color-background-soft);
  border-radius: 6px;
  margin: 1rem 0;
}
</style>
