<script setup lang="ts">
import axios from "axios";
import { ref, computed, watch, onMounted } from "vue";
import { API_URL } from "./consts";
import type { AssetInfo, FormValues } from "./types";
import { filterChainsForWallet } from "./evm";

const props = defineProps<{
  loading: boolean;
  originChain: string;
  isEvmOrigin?: boolean;
}>();

const emit = defineEmits<{
  submit: [values: FormValues];
  originChange: [origin: string];
}>();

const chains = ref<string[]>([]);
const destinationChain = ref("Hydration");
const supportedAssets = ref<AssetInfo[]>([]);
const currencyOptionId = ref("");
const currencyTo = ref("DOT");
const swapEnabled = ref(false);
const exchange = ref("");
const recipient = ref(
  "5F5586mfsnM6durWRLptYt3jSUs55KEmahdodQ5tQMr9iY96",
);
const amount = ref("5");

const fetchChains = async () => {
  const response = await axios.get(`${API_URL}/chains`);
  chains.value = response.data as string[];
};

onMounted(() => {
  void fetchChains();
});

const originChains = computed(() =>
  filterChainsForWallet(chains.value, props.isEvmOrigin ?? false),
);

watch(
  () => props.originChain,
  () => {},
);

watch(
  [() => props.originChain, destinationChain],
  async () => {
    const response = await axios.get(
      `${API_URL}/supported-assets?origin=${props.originChain}&destination=${destinationChain.value}`,
    );
    supportedAssets.value = response.data as AssetInfo[];
  },
  { immediate: true },
);

const currencyMap = computed(() =>
  supportedAssets.value.reduce(
    (map: Record<string, AssetInfo>, asset: AssetInfo) => {
      const key = `${asset.symbol ?? "NO_SYMBOL"}-${JSON.stringify(asset.location)}`;
      map[key] = asset;
      return map;
    },
    {},
  ),
);

const currencyOptions = computed(() =>
  Object.keys(currencyMap.value).map((key) => ({
    value: key,
    label: `${currencyMap.value[key].symbol ?? "Unknown"} - ${currencyMap.value[key].assetId ?? "Location"}`,
  })),
);

watch(
  currencyOptions,
  (opts) => {
    if (opts.length > 0) {
      currencyOptionId.value = opts[opts.length - 1].value;
    }
  },
  { immediate: true },
);

const onOriginSelect = (e: Event) => {
  const value = (e.target as HTMLSelectElement).value;
  emit("originChange", value);
};

const handleSubmit = (e: Event) => {
  e.preventDefault();
  emit("submit", {
    from: props.originChain,
    to: destinationChain.value,
    recipient: recipient.value,
    amount: amount.value,
    currency: currencyMap.value[currencyOptionId.value],
    swapEnabled: swapEnabled.value,
    currencyTo: swapEnabled.value ? currencyTo.value : undefined,
    exchange: swapEnabled.value && exchange.value ? exchange.value : undefined,
  });
};
</script>

<template>
  <form @submit="handleSubmit">
    <label>
      Origin chain
      <select
        :value="originChain"
        required
        @change="onOriginSelect"
      >
        <option
          v-for="chain in originChains"
          :key="chain"
          :value="chain"
        >
          {{ chain }}
        </option>
      </select>
    </label>

    <label>
      Destination chain
      <select
        v-model="destinationChain"
        required
      >
        <option
          v-for="chain in chains"
          :key="chain"
          :value="chain"
        >
          {{ chain }}
        </option>
      </select>
    </label>

    <label>
      Currency
      <select
        v-model="currencyOptionId"
        required
      >
        <option
          v-for="option in currencyOptions"
          :key="option.value"
          :value="option.value"
        >
          {{ option.label }}
        </option>
      </select>
    </label>

    <label>
      Recipient address
      <input
        v-model="recipient"
        type="text"
        required
      >
    </label>

    <label>
      Amount
      <input
        v-model="amount"
        type="number"
        required
      >
    </label>

    <template v-if="!isEvmOrigin">
      <button
        type="button"
        class="secondary"
        @click="swapEnabled = !swapEnabled"
      >
        {{ swapEnabled ? "- Remove Swap" : "+ Add Swap" }}
      </button>

      <template v-if="swapEnabled">
        <label>
          Exchange
          <input
            v-model="exchange"
            type="text"
            placeholder="Leave empty for auto"
          >
        </label>

        <label>
          Currency To
          <input
            v-model="currencyTo"
            type="text"
            required
          >
        </label>
      </template>
    </template>

    <button
      type="submit"
      :disabled="loading"
    >
      {{ loading ? "Submitting..." : "Submit transaction" }}
    </button>
  </form>
</template>
