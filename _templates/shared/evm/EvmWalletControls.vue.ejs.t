<script setup lang="ts">
import type { EvmAccountOption, EvmProviderOption } from "../../types";

defineProps<{
  providerOptions: EvmProviderOption[];
  selectedProviderUuid: string | undefined;
  accounts: EvmAccountOption[];
  selectedAddress: string | undefined;
}>();

const emit = defineEmits<{
  connectClick: [];
  providerChange: [uuid: string];
  accountChange: [address: string];
  disconnect: [];
}>();
</script>

<template>
  <div v-if="providerOptions.length > 0">
    <h4>Select provider:</h4>
    <select
      :value="selectedProviderUuid ?? ''"
      @change="
        ($event.target as HTMLSelectElement).value &&
          emit('providerChange', ($event.target as HTMLSelectElement).value)
      "
    >
      <option disabled value="">
        -- select an option --
      </option>
      <option
        v-for="{ uuid, label } in providerOptions"
        :key="uuid"
        :value="uuid"
      >
        {{ label }}
      </option>
    </select>
  </div>
  <button
    v-else
    type="button"
    @click="emit('connectClick')"
  >
    Connect Wallet
  </button>

  <div v-if="accounts.length > 0">
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
