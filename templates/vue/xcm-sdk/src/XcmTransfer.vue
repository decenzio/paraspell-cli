<script setup lang="ts">
import { ref } from "vue";
import TransferForm from "./XcmTransferForm.vue";
import type { FormValues } from "./types";
import {
  connectInjectedExtension,
  getInjectedExtensions,
  type InjectedExtension,
  type InjectedPolkadotAccount,
  type PolkadotSigner,
} from "polkadot-api/pjs-signer";
import { Builder } from "@paraspell/sdk";
import { submitTransaction } from "./utils";

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

const submitUsingSdk = async (
  formValues: FormValues,
  signer: PolkadotSigner,
) => {
  const { from, to, recipient, amount, swapEnabled, currencyTo, exchange } =
    formValues;

  if (!selectedAccount.value) {
    alert("No account selected, connect wallet first");
    return;
  }

  if (swapEnabled) {
    const builder = Builder()
      .from(from)
      .to(to)
      .currency({ location: formValues.currency!.location, amount })
      .recipient(recipient)
      .swap({
        currencyTo: { location: currencyTo!.location },
        ...(exchange ? { exchange: [exchange] } : {}),
      })
      .sender(selectedAccount.value.address);

    const txs = await builder.buildAll();

    for (const txContext of txs) {
      await submitTransaction(txContext.tx, signer);
    }
  } else {
    const tx = await Builder()
      .from(from)
      .to(to)
      .currency({ location: formValues.currency!.location, amount })
      .recipient(recipient)
      .sender(selectedAccount.value.address)
      .build();

    await submitTransaction(tx, signer);
  }
};

const onSubmit = async (formValues: FormValues) => {
  if (!selectedAccount.value || !selectedExtension.value) {
    alert("No account selected, connect wallet first");
    return;
  }

  loading.value = true;
  const signer = selectedAccount.value.polkadotSigner;

  try {
    await submitUsingSdk(formValues, signer);
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
