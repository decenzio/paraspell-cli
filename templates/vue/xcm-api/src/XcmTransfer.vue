<script setup lang="ts">
import { ref } from "vue";
import TransferForm from "./XcmTransferForm.vue";
import type { FormValues, ApiTransaction } from "./types";
import { fetchFromApi } from "./fetchFromApi";
import { submitTransaction } from "./utils";
import {
  connectInjectedExtension,
  getInjectedExtensions,
  type InjectedExtension,
  type InjectedPolkadotAccount,
  type PolkadotSigner,
} from "polkadot-api/pjs-signer";
import { Binary } from "polkadot-api";
import { createWsClient } from "polkadot-api/ws";
import axios from "axios";
import { API_URL } from "./consts";

const errorVisible = ref(false);
const error = ref<Error | null>(null);
const loading = ref(false);
const extensions = ref<string[]>([]);
const selectedExtension = ref<InjectedExtension | null>(null);
const accounts = ref<InjectedPolkadotAccount[]>([]);
const selectedAccount = ref<InjectedPolkadotAccount | undefined>();

const initAccounts = async () => {
  const list = getInjectedExtensions();

  if (list.length === 0) {
    alert("No wallet extension found, install it to connect");
    throw new Error("No Wallet Extension Found!");
  }

  extensions.value = list;
};

const submitApiTransaction = async (
  apiTx: ApiTransaction,
  signer: PolkadotSigner,
) => {
  const response = await axios.get(
    `${API_URL}/chains/${apiTx.chain}/ws-endpoints`,
  );
  const endpoints = response.data as string[];
  if (endpoints.length === 0) {
    throw new Error(`No WS endpoints found for chain ${apiTx.chain}`);
  }

  const client = createWsClient(endpoints[0]);
  const callData = Binary.fromHex(apiTx.tx);
  const tx = await client.getUnsafeApi().txFromCallData(callData);
  await submitTransaction(tx, signer);
};

const submitUsingApi = async (
  formValues: FormValues,
  signer: PolkadotSigner,
) => {
  if (!selectedAccount.value) {
    alert("No account selected, connect wallet first");
    return;
  }

  const apiParams = {
    from: formValues.from,
    to: formValues.to,
    recipient: formValues.recipient,
    sender: selectedAccount.value.address,
    currency: {
      location: formValues.currency!.location,
      amount: formValues.amount,
    },
    ...(formValues.swapEnabled && formValues.currencyTo
      ? {
          swapOptions: {
            currencyTo: { symbol: formValues.currencyTo },
            ...(formValues.exchange
              ? { exchange: [formValues.exchange] }
              : {}),
          },
        }
      : {}),
  };

  const transactions = await fetchFromApi(apiParams);

  for (const apiTx of transactions) {
    await submitApiTransaction(apiTx, signer);
  }
};

const onSubmit = async (formValues: FormValues) => {
  if (!selectedAccount.value) {
    alert("No account selected, connect wallet first");
    return;
  }

  loading.value = true;
  const signer = selectedAccount.value.polkadotSigner;

  try {
    await submitUsingApi(formValues, signer);
    alert("Transaction was successful!");
  } catch (e) {
    error.value = e as Error;
    errorVisible.value = true;
  } finally {
    loading.value = false;
  }
};

const onExtensionSelect = async (name: string) => {
  const injectedExtension = await connectInjectedExtension(name);
  selectedExtension.value = injectedExtension;

  const accs = injectedExtension.getAccounts();
  accounts.value = accs;

  if (accs.length > 0) {
    selectedAccount.value = accs[0];
  }
};

const onAccountChange = (address: string) => {
  selectedAccount.value = accounts.value.find((acc) => acc.address === address);
};
</script>

<template>
  <div>
    <div class="formHeader">
      <div v-if="extensions.length > 0">
        <h4>Select extension:</h4>
        <select
          :value="selectedExtension?.name ?? ''"
          @change="
            onExtensionSelect(($event.target as HTMLSelectElement).value)
          "
        >
          <option
            disabled
            value=""
          >
            -- select an option --
          </option>
          <option
            v-for="name in extensions"
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
        @click="initAccounts"
      >
        Connect Wallet
      </button>

      <div v-if="accounts.length > 0">
        <h4>Select account:</h4>
        <select
          :value="selectedAccount?.address"
          @change="
            onAccountChange(($event.target as HTMLSelectElement).value)
          "
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
    </div>
    <TransferForm
      :loading="loading"
      @submit="onSubmit"
    />
    <div v-if="errorVisible">
      <p>{{ error?.message }}</p>
    </div>
  </div>
</template>
