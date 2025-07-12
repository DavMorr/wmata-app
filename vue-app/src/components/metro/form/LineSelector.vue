<template>
  <div class="form-group">
    <label for="line">Line:</label>
    <select
      id="line"
      :value="modelValue"
      @change="$emit('update:modelValue', $event.target.value)"
      required
    >
      <option value="" disabled>Select a line</option>
      <option v-for="line in lines" :key="line.value" :value="line.value">
        {{ line.label }}
      </option>
    </select>
  </div>
</template>

<script setup>
defineProps({
  modelValue: {
    type: String,
    required: true,
  },
  lines: {
    type: Array,
    required: true,
  },
})

defineEmits(['update:modelValue'])
</script>

<style scoped>
.form-group {
  margin-bottom: 1.5rem;
  width: 100%;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--color-text);
}

.form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid var(--color-border);
  border-radius: 6px;
  font-size: 1rem;
  background: var(--color-background);
  color: var(--color-text);
  transition: border-color 0.3s;
  appearance: none;
  background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
  background-repeat: no-repeat;
  background-position: right 1rem center;
  background-size: 1em;
}

.form-group select:focus {
  outline: none;
  border-color: hsla(160, 100%, 37%, 1);
}
</style>
