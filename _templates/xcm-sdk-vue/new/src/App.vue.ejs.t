---
to: src/App.vue
---
<script setup lang="ts">
import "./App.css";<% if (swap) { %>
import "@paraspell/swap";<% } %><% if (evm) { %>
import "@paraspell/evm";<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %>
import XcmTransfer from "./XcmTransfer.vue";
</script>

<template>
  <div class="header">
    <h1>Vite + Vue +</h1>
    <a
      href="https://paraspell.github.io/docs/xcm-sdk/getting-started.html"
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
