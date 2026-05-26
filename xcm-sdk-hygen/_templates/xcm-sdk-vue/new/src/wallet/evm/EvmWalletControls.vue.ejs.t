---
to: src/wallet/evm/EvmWalletControls.vue
skip_if: <%= (!evm).toString() %>
---
<script setup lang="ts">
import type { EvmAccountOption } from "./useEvmWallet";

defineProps<{
  accounts: EvmAccountOption[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onAccountChange: (address: string) => void;
  onDisconnect?: () => void;
}>();
</script>

<template>
  <div class="formHeader">
    <button
      v-if="accounts.length === 0"
      type="button"
      @click="onConnectClick"
    >
      Connect Wallet
    </button>
    <div v-else>
      <h4>Select account:</h4>
      <select
        :value="selectedAddress ?? ''"
        @change="onAccountChange(($event.target as HTMLSelectElement).value)"
      >
        <option
          v-for="{ label, address } in accounts"
          :key="address"
          :value="address"
        >
          {{ label }} — {{ address }}
        </option>
      </select>
    </div>
    <button
      v-if="selectedAddress && onDisconnect"
      type="button"
      class="secondary"
      @click="onDisconnect"
    >
      Disconnect
    </button>
  </div>
</template>
