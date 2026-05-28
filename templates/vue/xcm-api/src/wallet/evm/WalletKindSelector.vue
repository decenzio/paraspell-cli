<script setup lang="ts">
export type WalletKind = "substrate" | "evm";

const WALLET_KIND_OPTIONS: { value: WalletKind; label: string }[] = [
  { value: "substrate", label: "Substrate" },
  { value: "evm", label: "EVM" },
];

defineProps<{
  activeWalletKind: WalletKind;
}>();

const emit = defineEmits<{
  "update:activeWalletKind": [kind: WalletKind];
}>();
</script>

<template>
  <div>
    <h4>Wallet type:</h4>
    <select
      :value="activeWalletKind"
      @change="
        emit(
          'update:activeWalletKind',
          ($event.target as HTMLSelectElement).value as WalletKind,
        )
      "
    >
      <option
        v-for="{ value, label } in WALLET_KIND_OPTIONS"
        :key="value"
        :value="value"
      >
        {{ label }}
      </option>
    </select>
  </div>
</template>
