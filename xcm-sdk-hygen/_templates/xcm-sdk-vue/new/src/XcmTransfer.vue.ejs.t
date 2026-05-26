---
to: src/XcmTransfer.vue
---
<script setup lang="ts">
import { ref, unref } from "vue";
import TransferForm from "./XcmTransferForm.vue";
import type { FormValues } from "./types";
import type { TChain } from "@paraspell/sdk";<% if (evm) { %>
import { getOriginChainsForWallet, isChainEvm } from "./evm";<% } %>
import {
  <% if (evm) { %>useWallet,
  WalletControls,
  WalletKindSelector,<% } else if (client === 'pjs') { %>usePjsWallet,
  PjsWalletControls,<% } else if (client === 'papi') { %>usePapiWallet,
  PapiWalletControls,<% } else { %>useDedotWallet,
  DedotWalletControls,<% } %>
} from "./wallet/<%= clientDir %>";<% if (!evm) { %>
import { submitUsingSdk } from "./xcm/<%= client %>";<% if (client === 'papi') { %>
import type { PolkadotSigner } from "polkadot-api";<% } else { %>
import type { Signer } from "@polkadot/api/types";<% } %><% } %>

const errorVisible = ref(false);
const error = ref<Error | null>(null);
const loading = ref(false);
const originChain = ref<TChain>("Astar");

<% if (evm) { %>const wallet = useWallet();<% } else if (client === 'pjs') { %>const wallet = usePjsWallet();<% } else if (client === 'papi') { %>const wallet = usePapiWallet();<% } else { %>const wallet = useDedotWallet();<% } %>

<% if (evm) { %>const handleOriginChange = (origin: TChain) => {
  originChain.value = origin;
  wallet.setActiveWalletKind(isChainEvm(origin) ? "evm" : "substrate");
};

const setWalletKind = (kind: typeof wallet.activeWalletKind.value) => {
  wallet.setActiveWalletKind(kind);
  const allowed = getOriginChainsForWallet(kind === "evm");
  if (!allowed.includes(originChain.value)) {
    originChain.value = allowed[0];
  }
};<% } else { %>const handleOriginChange = (origin: TChain) => {
  originChain.value = origin;
};<% } %>

const onSubmit = async (formValues: FormValues) => {
  loading.value = true;
  errorVisible.value = false;

  try {
    <% if (evm) { %>const mismatch = wallet.getOriginMismatchError(formValues.from);
    if (mismatch) {
      error.value = new Error(mismatch);
      errorVisible.value = true;
      return;
    }

    await wallet.submitTransfer(formValues);<% } else { %>const connection = unref(wallet.connection);
    if (!connection) {
      alert("No account selected, connect wallet first");
      return;
    }

    <% if (client === 'papi') { %>await submitUsingSdk(
      formValues,
      connection.signer as PolkadotSigner,
      connection.address,
    );<% } else { %>await submitUsingSdk(
      formValues,
      connection.signer as Signer,
      connection.address,
    );<% } %><% } %>
    alert("Transaction was successful!");
  } catch (e) {
    error.value = e as Error;
    errorVisible.value = true;
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="transferLayout">
    <% if (evm) { %>
    <WalletKindSelector
      :active-wallet-kind="wallet.activeWalletKind.value"
      @update:active-wallet-kind="setWalletKind"
    />
    <WalletControls :wallet="wallet" />
    <% } else if (client === 'pjs') { %>
    <PjsWalletControls
      :extension-names="wallet.extensionNames"
      :selected-extension-name="wallet.selectedExtensionName"
      :accounts="wallet.accounts"
      :selected-address="wallet.selectedAddress"
      :on-connect-click="() => { void wallet.discoverExtensions(); }"
      :on-extension-change="(name: string) => { void wallet.selectExtension(name); }"
      :on-account-change="wallet.selectAccountByAddress"
    />
    <% } else if (client === 'papi') { %>
    <PapiWalletControls
      :extension-names="wallet.extensionNames"
      :selected-extension-name="wallet.selectedExtensionName"
      :accounts="wallet.accounts"
      :selected-address="wallet.selectedAddress"
      :on-connect-click="() => { void wallet.discoverExtensions(); }"
      :on-extension-change="(name: string) => { void wallet.selectExtension(name); }"
      :on-account-change="wallet.selectAccountByAddress"
    />
    <% } else { %>
    <DedotWalletControls
      :extension-names="wallet.extensionNames"
      :selected-extension-name="wallet.selectedExtensionName"
      :accounts="wallet.accounts"
      :selected-address="wallet.selectedAddress"
      :on-connect-click="() => { void wallet.discoverExtensions(); }"
      :on-extension-change="(name: string) => { void wallet.selectExtension(name); }"
      :on-account-change="wallet.selectAccountByAddress"
    />
    <% } %>
    <TransferForm
      :loading="loading"
      :origin-chain="originChain"
      @submit="onSubmit"
      @origin-change="handleOriginChange"<% if (evm) { %>
      :is-evm-origin="wallet.activeWalletKind.value === 'evm'"<% } %>
    />
    <p
      v-if="errorVisible"
      class="transferError"
    >
      {{ error?.message }}
    </p>
  </div>
</template>
