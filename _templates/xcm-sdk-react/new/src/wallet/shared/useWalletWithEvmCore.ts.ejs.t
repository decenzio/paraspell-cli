---
to: src/wallet/shared/useWalletWithEvmCore.ts
skip_if: <%= (!evmWallet).toString() %>
---
import { useCallback, useEffect, useState } from "react";
import type { TChain } from "<%= sdkPackage %>";
import { useEvmWallet } from "../evm/useEvmWallet";
import type { WalletKind } from "../evm/WalletKindSelector";
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

  const [activeWalletKind, setActiveWalletKind] =
    useState<WalletKind>("substrate");

  useEffect(() => {
    if (activeWalletKind !== "substrate") return;
    if (substrate.accounts.length > 0) return;
    if (substrate.extensionNames.length === 0) return;

    const name =
      substrate.selectedExtensionName ?? substrate.extensionNames[0];
    void substrate.selectExtension(name);
  }, [
    activeWalletKind,
    substrate.accounts.length,
    substrate.extensionNames,
    substrate.selectedExtensionName,
    substrate.selectExtension,
  ]);

  const buildSubmitOptions = useCallback(
    (from: TChain): WalletSubmitOptions<TSigner> | null => {
      if (activeWalletKind === "evm") {
        const walletClient = evm.getWalletClient(from);
        if (!walletClient || !evm.selectedProvider) return null;
        return {
          kind: "evm",
          walletClient,
          provider: evm.selectedProvider.provider,
        };
      }

      if (!substrate.connection) return null;
      const payload = toSubstratePayload(substrate.connection);
      return {
        kind: "substrate",
        signer: payload.signer,
        senderAddress: payload.senderAddress,
      };
    },
    [activeWalletKind, evm, substrate.connection, toSubstratePayload],
  );

  return {
    ...substrate,
    connection:
      activeWalletKind === "substrate" ? substrate.connection : null,
    selectedAddress:
      activeWalletKind === "evm"
        ? evm.selectedAddress
        : substrate.selectedAddress,
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
