---
to: src/wallet/shared/useWalletWithEvmCore.ts
skip_if: <%= (!evmWallet).toString() %>
---
import { computed, ref, unref } from "vue";
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
      if (!walletClient || !evm.selectedProvider.value) return null;
      return {
        kind: "evm",
        walletClient,
        provider: evm.selectedProvider.value.provider,
      };
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
    evmAccounts: evm.accounts,
    evmProviderOptions: evm.providerOptions,
    selectedEvmProviderUuid: evm.selectedProviderUuid,
    discoverEvmProviders: evm.discoverProviders,
    selectEvmProvider: evm.selectProvider,
    selectEvmAccount: evm.selectAccountByAddress,
    disconnectEvm: evm.disconnect,
    getEvmWalletClient: evm.getWalletClient,
  };
}
