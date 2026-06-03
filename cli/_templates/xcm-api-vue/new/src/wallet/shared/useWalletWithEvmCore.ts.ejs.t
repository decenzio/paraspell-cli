---
to: src/wallet/shared/useWalletWithEvmCore.ts
skip_if: <%= (!evm).toString() %>
---
import { computed, ref, unref } from "vue";
import { isChainEvm } from "../../evm";
import { useEvmWallet } from "../evm/useEvmWallet";
import type { WalletKind } from "../evm/WalletKindSelector.vue";
import type {
  SubstrateWalletBase,
  SubstrateWalletConnection,
  WalletSubmitOptions,
} from "./types";

export type SubstrateSubmitPayload<TSigner> = {
  signer: TSigner;
  senderAddress: string;
};

export function useWalletWithEvmCore<
  TSigner,
  TSubstrate extends SubstrateWalletBase<TSigner>,
>(
  substrate: TSubstrate,
  toSubstratePayload: (
    connection: SubstrateWalletConnection<TSigner>,
  ) => SubstrateSubmitPayload<TSigner>,
) {
  const evm = useEvmWallet();
  const activeWalletKind = ref<WalletKind>("substrate");

  const buildSubmitOptions = (
    from: string,
  ): WalletSubmitOptions<TSigner> | null => {
    if (activeWalletKind.value === "evm") {
      const walletClient = evm.getWalletClient(from);
      if (!walletClient) return null;
      return { kind: "evm", walletClient };
    }

    const substrateConnection = unref(substrate.connection);
    if (!substrateConnection) return null;
    const payload = toSubstratePayload(substrateConnection);
    return {
      kind: "substrate",
      signer: payload.signer,
      senderAddress: payload.senderAddress,
    };
  };

  const getOriginMismatchError = (from: string): string | null => {
    const originIsEvm = isChainEvm(from);
    if (originIsEvm && activeWalletKind.value === "substrate") {
      return "This origin requires an EVM wallet. Switch wallet type to EVM.";
    }
    if (!originIsEvm && activeWalletKind.value === "evm") {
      return "This origin requires a Substrate wallet. Switch wallet type to Substrate.";
    }
    return null;
  };

  const connection = computed(() =>
    activeWalletKind.value === "substrate" ? unref(substrate.connection) : null,
  );

  const selectedAddress = computed(() =>
    activeWalletKind.value === "evm"
      ? evm.selectedAddress.value
      : unref(substrate.selectedAddress),
  );

  const setActiveWalletKind = (kind: WalletKind) => {
    activeWalletKind.value = kind;
  };

  return {
    ...substrate,
    connection,
    selectedAddress,
    activeWalletKind,
    setActiveWalletKind,
    buildSubmitOptions,
    getOriginMismatchError,
    evmAccounts: evm.accounts,
    connectEvm: evm.connect,
    selectEvmAccount: evm.selectAccountByAddress,
    disconnectEvm: evm.disconnect,
    getEvmWalletClient: evm.getWalletClient,
  };
}
