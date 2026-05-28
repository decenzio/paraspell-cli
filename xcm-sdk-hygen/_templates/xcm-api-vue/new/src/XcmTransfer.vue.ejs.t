---
to: src/XcmTransfer.vue
---
<script setup lang="ts">
import { ref } from "vue";
import TransferForm from "./XcmTransferForm.vue";
import type { FormValues } from "./types";
<% if (evm) { %>
import { getOriginChainsForWallet, isChainEvm } from "./evm";
import {
  useWallet,
  WalletControls,
  WalletKindSelector,
} from "./wallet/papi";
<% } else { %>
import type { PolkadotSigner } from "polkadot-api";
import { usePapiWallet } from "./wallet/papi";
import PapiWalletControls from "./wallet/papi/PapiWalletControls.vue";
import { submitUsingApi } from "./submit/submitUsingApi";
<% } %>

const errorVisible = ref(false);
const error = ref<Error | null>(null);
const loading = ref(false);
const originChain = ref("Astar");

<% if (evm) { %>
const wallet = useWallet();

const handleOriginChange = (origin: string) => {
  originChain.value = origin;
  wallet.setActiveWalletKind(isChainEvm(origin) ? "evm" : "substrate");
};

const setWalletKind = (kind: typeof wallet.activeWalletKind.value) => {
  wallet.setActiveWalletKind(kind);
  const allowed = getOriginChainsForWallet(kind === "evm");
  if (!allowed.includes(originChain.value)) {
    originChain.value = allowed[0];
  }
};
<% } else { %>
const wallet = usePapiWallet();
<% } %>

const onSubmit = async (formValues: FormValues) => {
  loading.value = true;
  errorVisible.value = false;

  try {
    <% if (evm) { %>
    const mismatch = wallet.getOriginMismatchError(formValues.from);
    if (mismatch) {
      error.value = new Error(mismatch);
      errorVisible.value = true;
      return;
    }

    await wallet.submitTransfer(formValues);
    <% } else { %>
    if (!wallet.connection.value) {
      alert("No account selected, connect wallet first");
      return;
    }

    await submitUsingApi(
      formValues,
      wallet.connection.value.signer as PolkadotSigner,
      wallet.connection.value.address,
    );
    <% } %>
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
  <div>
    <% if (evm) { %>
    <div class="formHeader">
      <WalletKindSelector
        :active-wallet-kind="wallet.activeWalletKind.value"
        @update:active-wallet-kind="setWalletKind"
      />
      <WalletControls :wallet="wallet" />
    </div>
    <% } else { %>
    <div class="formHeader">
    <PapiWalletControls
      :extension-names="wallet.extensionNames"
      :selected-extension-name="wallet.selectedExtensionName"
      :accounts="wallet.accounts"
      :selected-address="wallet.selectedAddress"
      :on-connect-click="() => void wallet.discoverExtensions()"
      :on-extension-change="(name: string) => void wallet.selectExtension(name)"
      :on-account-change="wallet.selectAccountByAddress"
    />
    </div>
    <% } %>
    <TransferForm
      :loading="loading"
      :origin-chain="originChain"
      <% if (evm) { %>
      :is-evm-origin="wallet.activeWalletKind.value === 'evm'"
      @origin-change="handleOriginChange"
      <% } else { %>
      @origin-change="(o: string) => (originChain = o)"
      <% } %>
      @submit="onSubmit"
    />
    <p
      v-if="errorVisible"
      class="transferError"
    >
      {{ error?.message }}
    </p>
  </div>
</template>
