<script setup>
import { RouterLink, RouterView } from 'vue-router'
import NavView from './views/NavView.vue'
</script>

<template>
  <div id="tpl-root">
    <header>
      <NavView />
    </header>

    <main class="main-content">
      <RouterView />
    </main>
  </div>
</template>

<style>
#tpl-root {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  background: var(--color-background);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  z-index: 1000;
}

.main-content {
  margin-top: 60px; /* Height of the header */
  padding: 2rem;
  flex: 1;
  width: 100%;
  max-width: 1280px;
  margin-left: auto;
  margin-right: auto;
}

@media (min-width: 1024px) {
  .main-content {
    padding: 3rem 2rem;
  }
}
</style>
