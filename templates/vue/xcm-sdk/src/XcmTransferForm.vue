<script setup lang="ts">
import { computed, ref, watch } from "vue";
import useCurrencyOptions from "./useCurrencyOptions";
import {
  CHAINS,
  EXCHANGE_CHAINS,
  type TChain,
  type TExchangeChain,
} from "@paraspell/sdk";
import type { FormValues } from "./types";
import { getOriginChainsForWallet } from "./evm";

const props = defineProps<{
  loading: boolean;
  originChain: TChain;
  isEvmOrigin?: boolean;
}>();

const emit = defineEmits<{
  submit: [values: FormValues];
  originChange: [origin: TChain];
}>();

const destinationChain = ref<TChain>("Hydration");
const currencyOptionId = ref("");
const currencyToOptionId = ref("");
const swapEnabled = ref(false);
const exchange = ref<TExchangeChain | undefined>(undefined);
const recipient = ref("5F5586mfsnM6durWRLptYt3jSUs55KEmahdodQ5tQMr9iY96");
const amount = ref("5");

const originChains = computed(() =>
  getOriginChainsForWallet(props.isEvmOrigin ?? false),
);

const from = computed(() => props.originChain);
const to = computed(() => destinationChain.value);

const { currencyOptions, currencyMap, currencyToOptions, currencyToMap } =
  useCurrencyOptions(from, to, swapEnabled, exchange);

watch(
  currencyOptions,
  (opts) => {
    if (opts.length > 0) {
      currencyOptionId.value = opts[opts.length - 1].value;
    }
  },
  { immediate: true },
);

watch(
  currencyToOptions,
  (opts) => {
    if (opts.length > 0) {
      currencyToOptionId.value = opts[opts.length - 1].value;
    }
  },
  { immediate: true },
);

const onExchangeChange = (e: Event) => {
  const v = (e.target as HTMLSelectElement).value;
  exchange.value = v ? (v as TExchangeChain) : undefined;
};

const handleSubmit = (e: Event) => {
  e.preventDefault();
  emit("submit", {
    from: props.originChain,
    to: destinationChain.value,
    currencyOptionId: currencyOptionId.value,
    recipient: recipient.value,
    amount: amount.value,
    currency: currencyMap.value[currencyOptionId.value],
    swapEnabled: swapEnabled.value,
    currencyTo: swapEnabled.value
      ? currencyToMap.value[currencyToOptionId.value]
      : undefined,
    exchange: exchange.value,
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
        :disabled="loading"
        @change="
          emit('originChange', ($event.target as HTMLSelectElement).value as TChain)
        "
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
        :disabled="loading"
      >
        <option
          v-for="chain in CHAINS"
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
          v-for="currency in currencyOptions"
          :key="currency.value"
          :value="currency.value"
        >
          {{ currency.label }}
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
        <select
          :value="exchange ?? ''"
          @change="onExchangeChange"
        >
          <option value="">
            Auto
          </option>
          <option
            v-for="chain in EXCHANGE_CHAINS"
            :key="chain"
            :value="chain"
          >
            {{ chain }}
          </option>
        </select>
      </label>

      <label>
        Currency To
        <select
          v-model="currencyToOptionId"
          required
        >
          <option
            v-for="currency in currencyToOptions"
            :key="currency.value"
            :value="currency.value"
          >
            {{ currency.label }}
          </option>
        </select>
      </label>
    </template>

    <button
      type="submit"
      :disabled="loading"
    >
      {{ loading ? "Submitting..." : "Submit transaction" }}
    </button>
  </form>
</template>
