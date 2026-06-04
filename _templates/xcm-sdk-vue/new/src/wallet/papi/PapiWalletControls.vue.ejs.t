---
to: src/wallet/papi/PapiWalletControls.vue
skip_if: <%= (client !== 'papi').toString() %>
---
<script setup lang="ts">
import type { InjectedPolkadotAccount } from "polkadot-api/pjs-signer";

defineProps<{
  extensionNames: string[];
  selectedExtensionName: string | undefined;
  accounts: InjectedPolkadotAccount[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onExtensionChange: (name: string) => void;
  onAccountChange: (address: string) => void;
}>();
</script>

<template>
  <div v-if="extensionNames.length > 0">
      <h4>Select extension:</h4>
      <select
        :value="selectedExtensionName"
        @change="
          ($event.target as HTMLSelectElement).value &&
            onExtensionChange(($event.target as HTMLSelectElement).value)
        "
      >
        <option
          disabled
          value=""
        >
          -- select an option --
        </option>
        <option
          v-for="name in extensionNames"
          :key="name"
          :value="name"
        >
          {{ name }}
        </option>
      </select>
    </div>
    <button
      v-else
      type="button"
      @click="onConnectClick"
    >
      Connect Wallet
    </button>

    <div v-if="accounts.length > 0">
      <h4>Select account:</h4>
      <select
        :value="selectedAddress"
        @change="onAccountChange(($event.target as HTMLSelectElement).value)"
      >
        <option
          v-for="{ name, address } in accounts"
          :key="address"
          :value="address"
        >
          {{ name }} - {{ address }}
        </option>
      </select>
  </div>
</template>
