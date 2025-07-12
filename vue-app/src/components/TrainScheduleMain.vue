<script setup>
defineProps({
  msg: {
    type: String,
    required: true,
  },
})
</script>

<template>
  <div class="train-schedule-main train-schedule-form-wrapper">
    <div class="greetings">
      <h1 class="green">{{ msg }}</h1>
    </div>
    <div class="train-schedule-form">
      <h2>Train Schedule Form</h2>
      <form>
        <div class="form-group">
          <label for="line">Line:</label>
          <select id="line" name="line" required>
            <option value="" disabled selected>Select a line</option>
            <option value="blue">Blue Line</option>
            <option value="green">Green Line</option>
            <option value="orange">Orange Line</option>
            <option value="red">Red Line</option>
            <option value="orange">Silver Line</option>
            <option value="yellow">Yellow Line</option>
          </select>
        </div>

        <div class="form-group">
          <label for="station">Station:</label>
          <select id="station" name="station" required>
            <
            <option value="station-1">Station 1</option>
            <option value="station-2">Station 2</option>
            <option value="station-3">Station 3</option>
            <option value="station-4">Station 4</option>
            <option value="station-5">Station 5</option>
          </select>
        </div>

        <div class="form-group">
          <label for="direction">Direction:</label>
          <select id="direction" name="direction" required>
            <option value="" disabled selected>Select a direction</option>
            <option value="north">North</option>
            <option value="south">South</option>
            <option value="east">East</option>
            <option value="west">West</option>
          </select>
        </div>

        <div class="form-group button-wrapper">
          <button type="submit">Get Schedule</button>
        </div>
      </form>

      <div class="schedule-results">
        <h3>Schedule Results</h3>
        <p>No results yet. Please fill out the form and submit.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
label {
  display: inline-block;
  min-width: 100px;
  margin-right: 0.5rem;
  text-align: right;
}
select {
  width: 300px;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button {
  padding: 0.5rem;
  border-radius: 4px;
}
.form-group {
  margin-bottom: 1rem;
}
.form-group.button-wrapper {
  display: flex;
  justify-content: center;
  text-align: center;
}
</style>
