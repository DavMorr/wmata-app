<template>
  <nav>
    <div class="nav-container">
      <RouterLink to="/" class="nav-link">Home</RouterLink>
      <RouterLink to="/about" class="nav-link">About</RouterLink>
      <RouterLink to="/api-test" class="nav-link">API Test</RouterLink>
    </div>
  </nav>
</template>

<style scoped>
nav {
  width: 100%;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-background);
  border-bottom: 1px solid var(--color-border);
}

.nav-container {
  width: 100%;
  max-width: 1280px;
  padding: 0 2rem;
  display: flex;
  align-items: center;
  gap: 2rem;
}

.nav-link {
  font-size: 1rem;
  color: var(--color-text);
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.nav-link:hover {
  background-color: var(--color-background-soft);
}

.nav-link.router-link-active {
  color: var(--color-heading);
  font-weight: 600;
  background-color: var(--color-background-mute);
}

@media (max-width: 768px) {
  .nav-container {
    justify-content: center;
    padding: 0 1rem;
    gap: 1rem;
  }

  .nav-link {
    padding: 0.5rem;
  }
}
</style>
