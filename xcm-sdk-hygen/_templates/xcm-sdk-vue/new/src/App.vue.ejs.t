---
to: src/App.vue
---
<script setup lang="ts">
import "./App.css";
import XcmTransfer from "./XcmTransfer.vue";<% if (swap) { %>
import "@paraspell/swap";<% } %>
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
  <p
    class="read-the-docs"
    style="font-size: 0.85rem; opacity: 0.7"
  >
    Generated with Hygen — client: <%= clientLabel %><% if (evm) { %>, EVM<% } %><% if (swap) { %>, Swap<% } %><% if (snowbridge) { %>, Snowbridge<% } %>
  </p>
</template>
