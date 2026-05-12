<script setup lang="ts">
import "./App.css";
import "@paraspell/swap";
import XcmTransfer from "./XcmTransfer.vue";
</script>

<template>
  <div class="header">
    <h1>Vite + Vue +</h1>
    <a
      href="https://paraspell.github.io/docs/sdk/getting-started.html"
      target="_blank"
      rel="noopener noreferrer"
      class="logo"
    >
      <img
        src="/paraspell.png"
        alt="ParaSpell logo"
      >
    </a>
  </div>
  <XcmTransfer />
  <p class="read-the-docs">
    Click on the ParaSpell logo to read the docs
  </p>
</template>
