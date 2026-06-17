---
to: src/wallet/evm/EvmWalletControls.vue
skip_if: <%= (!evmWallet).toString() %>
---
<script setup lang="ts">
import type { EvmAccountOption } from "./useEvmWallet";

defineProps<{
  accounts: EvmAccountOption[];
  selectedAddress: string | undefined;
}>();

const emit = defineEmits<{
  connectClick: [];
  accountChange: [address: string];
  disconnect: [];
}>();
</script>

<template>
  <button
      v-if="accounts.length === 0"
      type="button"
      @click="emit('connectClick')"
    >
      Connect Wallet
    </button>
    <div v-else>
      <h4>Select account:</h4>
      <select
        :value="selectedAddress"
        @change="emit('accountChange', ($event.target as HTMLSelectElement).value)"
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
      v-if="selectedAddress"
      type="button"
      class="secondary"
      @click="emit('disconnect')"
    >
      Disconnect
    </button>
</template>
