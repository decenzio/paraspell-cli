---
to: src/XcmTransfer.vue
---
<script setup lang="ts">
import { ref<% if (!evm) { %>, unref<% } %> } from "vue";
import TransferForm from "./XcmTransferForm.vue";
import type { FormValues } from "./types";
import type { <% if (evm) { %>TChain<% } else { %>TSubstrateChain<% } %> } from "@paraspell/sdk";
import {
  <% if (evm) { %>useWallet,
  WalletControls,
  WalletKindSelector,<% } else if (client === 'pjs') { %>usePjsWallet,
  PjsWalletControls,<% } else if (client === 'papi') { %>usePapiWallet,
  PapiWalletControls,<% } else { %>useDedotWallet,
  DedotWalletControls,<% } %>
} from "./wallet/<%= clientDir %>";<% if (!evm) { %>
import { submitUsingSdk } from "./xcm/<%= client %>";<% } %>

const toError = (error: unknown): Error =>
  error instanceof Error ? error : new Error("An unknown error occurred");

const errorVisible = ref(false);
const error = ref<Error | null>(null);
const loading = ref(false);
const originChain = ref<<% if (evm) { %>TChain<% } else { %>TSubstrateChain<% } %>>("Astar");

<% if (evm) { %>const wallet = useWallet();<% } else if (client === 'pjs') { %>const wallet = usePjsWallet();<% } else if (client === 'papi') { %>const wallet = usePapiWallet();<% } else { %>const wallet = useDedotWallet();<% } %>

<% if (evm) { %>const handleOriginChange = (origin: TChain) => {
  originChain.value = origin;
};

const setWalletKind = (kind: typeof wallet.activeWalletKind.value) => {
  wallet.setActiveWalletKind(kind);
};<% } else { %>const handleOriginChange = (origin: TSubstrateChain) => {
  originChain.value = origin;
};<% } %>

const onSubmit = async (formValues: FormValues) => {
  loading.value = true;
  errorVisible.value = false;

  try {
    <% if (evm) { %>const submitted = await wallet.submitTransfer(formValues);
    if (!submitted) return;<% } else { %>const connection = unref(wallet.connection);
    if (!connection) {
      alert("No account selected, connect wallet first");
      return;
    }

    <% if (client === 'papi') { %>await submitUsingSdk(
      formValues,
      connection.signer,
      connection.address,
    );<% } else { %>await submitUsingSdk(
      formValues,
      connection.signer,
      connection.address,
    );<% } %><% } %>
    alert("Transaction was successful!");
  } catch (e) {
    error.value = toError(e);
    errorVisible.value = true;
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="transferLayout">
    <% if (evm) { %>
    <div class="formHeader">
      <WalletKindSelector
        :active-wallet-kind="wallet.activeWalletKind.value"
        @update:active-wallet-kind="setWalletKind"
      />
      <WalletControls :wallet="wallet" />
    </div>
    <% } else if (client === 'pjs') { %>
    <div class="formHeader">
    <PjsWalletControls
      :extension-names="wallet.extensionNames"
      :selected-extension-name="wallet.selectedExtensionName"
      :accounts="wallet.accounts"
      :selected-address="wallet.selectedAddress"
      :on-connect-click="() => { void wallet.discoverExtensions(); }"
      :on-extension-change="(name: string) => { void wallet.selectExtension(name); }"
      :on-account-change="wallet.selectAccountByAddress"
    />
    </div>
    <% } else if (client === 'papi') { %>
    <div class="formHeader">
    <PapiWalletControls
      :extension-names="wallet.extensionNames"
      :selected-extension-name="wallet.selectedExtensionName"
      :accounts="wallet.accounts"
      :selected-address="wallet.selectedAddress"
      :on-connect-click="() => { void wallet.discoverExtensions(); }"
      :on-extension-change="(name: string) => { void wallet.selectExtension(name); }"
      :on-account-change="wallet.selectAccountByAddress"
    />
    </div>
    <% } else { %>
    <div class="formHeader">
    <DedotWalletControls
      :extension-names="wallet.extensionNames"
      :selected-extension-name="wallet.selectedExtensionName"
      :accounts="wallet.accounts"
      :selected-address="wallet.selectedAddress"
      :on-connect-click="() => { void wallet.discoverExtensions(); }"
      :on-extension-change="(name: string) => { void wallet.selectExtension(name); }"
      :on-account-change="wallet.selectAccountByAddress"
    />
    </div>
    <% } %>
    <TransferForm
      :loading="loading"
      :origin-chain="originChain"
      @submit="onSubmit"
      @origin-change="handleOriginChange"
    />
    <p
      v-if="errorVisible"
      class="transferError"
    >
      {{ error?.message }}
    </p>
  </div>
</template>
