<script setup lang="ts">
import { ref } from "vue";
import TransferForm from "./XcmTransferForm.vue";
import type { FormValues } from "./types";
import type { TChain } from "@paraspell/sdk";
import { getOriginChainsForWallet, isChainEvm } from "./evm";
import {
  useWallet,
  WalletControls,
  WalletKindSelector,
} from "./wallet/pjs";

const errorVisible = ref(false);
const error = ref<Error | null>(null);
const loading = ref(false);
const originChain = ref<TChain>("Astar");

const wallet = useWallet();

const handleOriginChange = (origin: TChain) => {
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

const onSubmit = async (formValues: FormValues) => {
  loading.value = true;
  errorVisible.value = false;

  try {
    const mismatch = wallet.getOriginMismatchError(formValues.from);
    if (mismatch) {
      error.value = new Error(mismatch);
      errorVisible.value = true;
      return;
    }

    await wallet.submitTransfer(formValues);
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
    <WalletKindSelector
      :active-wallet-kind="wallet.activeWalletKind.value"
      @update:active-wallet-kind="setWalletKind"
    />
    <WalletControls :wallet="wallet" />
    <TransferForm
      :loading="loading"
      :origin-chain="originChain"
      :is-evm-origin="wallet.activeWalletKind.value === 'evm'"
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
