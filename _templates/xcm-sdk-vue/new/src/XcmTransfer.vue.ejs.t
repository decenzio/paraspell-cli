---
to: src/XcmTransfer.vue
---
<script setup lang="ts">
import { ref } from "vue";
import TransferForm from "./XcmTransferForm.vue";
import type { FormValues } from "./types";
import type { TChain } from "@paraspell/sdk";
import {
  <% if (evmWallet) { %>useWallet,
  WalletControls,
  WalletKindSelector,<% } else if (client === 'pjs') { %>usePjsWallet,
  PjsWalletControls,<% } else if (client === 'papi') { %>usePapiWallet,
  PapiWalletControls,<% } else { %>useDedotWallet,
  DedotWalletControls,<% } %>
} from "./wallet/<%= clientDir %>";<% if (!evmWallet) { %>
import { submitUsingSdk } from "./xcm/<%= client %>";<% } -%>

const toError = (error: unknown): Error =>
  error instanceof Error
    ? error
    : error instanceof ErrorEvent
      ? new Error(error.message)
      : new Error("An unknown error occurred");

const errorVisible = ref(false);
const error = ref<Error | null>(null);
const loading = ref(false);
const originChain = ref<TChain>("Astar");

<% if (evmWallet) { %>const wallet = useWallet();

const handleOriginChange = (origin: TChain) => {
  originChain.value = origin;
};

const setWalletKind = (kind: typeof wallet.activeWalletKind.value) => {
  wallet.setActiveWalletKind(kind);
};
<% } else if (client === 'pjs') { %>const {
  extensionNames,
  selectedExtensionName,
  accounts,
  selectedAddress,
  connection,
  discoverExtensions,
  selectExtension,
  selectAccountByAddress,
} = usePjsWallet();

const handleOriginChange = (origin: TChain) => {
  originChain.value = origin;
};
<% } else if (client === 'papi') { %>const {
  extensionNames,
  selectedExtensionName,
  accounts,
  selectedAddress,
  connection,
  discoverExtensions,
  selectExtension,
  selectAccountByAddress,
} = usePapiWallet();

const handleOriginChange = (origin: TChain) => {
  originChain.value = origin;
};
<% } else { %>const {
  extensionNames,
  selectedExtensionName,
  accounts,
  selectedAddress,
  connection,
  discoverExtensions,
  selectExtension,
  selectAccountByAddress,
} = useDedotWallet();

const handleOriginChange = (origin: TChain) => {
  originChain.value = origin;
};
<% } -%>

const onSubmit = async (formValues: FormValues) => {
  loading.value = true;
  errorVisible.value = false;

  try {
    <% if (evmWallet) { %>const submitted = await wallet.submitTransfer(formValues);
    if (!submitted) return;<% } else { %>if (!connection.value) {
      alert("No account selected, connect wallet first");
      return;
    }

    <% if (client === 'papi') { %>await submitUsingSdk(
      formValues,
      connection.value.signer,
      connection.value.address,
    );<% } else { %>await submitUsingSdk(
      formValues,
      connection.value.signer,
      connection.value.address,
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
    <% if (evmWallet) { %>
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
      :extension-names="extensionNames"
      :selected-extension-name="selectedExtensionName"
      :accounts="accounts"
      :selected-address="selectedAddress"
      @connect-click="() => { void discoverExtensions(); }"
      @extension-change="(name: string) => { void selectExtension(name); }"
      @account-change="selectAccountByAddress"
    />
    </div>
    <% } else if (client === 'papi') { %>
    <div class="formHeader">
    <PapiWalletControls
      :extension-names="extensionNames"
      :selected-extension-name="selectedExtensionName"
      :accounts="accounts"
      :selected-address="selectedAddress"
      @connect-click="() => { void discoverExtensions(); }"
      @extension-change="(name: string) => { void selectExtension(name); }"
      @account-change="selectAccountByAddress"
    />
    </div>
    <% } else { %>
    <div class="formHeader">
    <DedotWalletControls
      :extension-names="extensionNames"
      :selected-extension-name="selectedExtensionName"
      :accounts="accounts"
      :selected-address="selectedAddress"
      @connect-click="() => { void discoverExtensions(); }"
      @extension-change="(name: string) => { void selectExtension(name); }"
      @account-change="selectAccountByAddress"
    />
    </div>
    <% } %>
    <TransferForm
      :loading="loading"
      :origin-chain="originChain"
      @submit="onSubmit"
      @origin-change="handleOriginChange"
    />
    <p v-if="errorVisible" class="transferError">{{ error?.message }}</p>
  </div>
</template>
