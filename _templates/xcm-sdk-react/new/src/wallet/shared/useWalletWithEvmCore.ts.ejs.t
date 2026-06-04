---
to: src/wallet/shared/useWalletWithEvmCore.ts
skip_if: <%= (!evm).toString() %>
---
import { useCallback, useState } from "react";
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

  const buildSubmitOptions = useCallback(
    (from: TChain): WalletSubmitOptions<TSigner> | null => {
      if (activeWalletKind === "evm") {
        const walletClient = evm.getWalletClient(from);
        if (!walletClient) return null;
        return { kind: "evm", walletClient };
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
    connectEvm: evm.connect,
    selectEvmAccount: evm.selectAccountByAddress,
    disconnectEvm: evm.disconnect,
    getEvmWalletClient: evm.getWalletClient,
  };
}
