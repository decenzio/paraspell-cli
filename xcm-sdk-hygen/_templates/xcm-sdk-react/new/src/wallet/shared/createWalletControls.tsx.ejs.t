---
to: src/wallet/shared/createWalletControls.tsx
skip_if: <%= (!evm).toString() %>
---
/* EVM_FEATURE — entire file */

import type { FC } from "react";
import { EvmWalletControls } from "../evm/EvmWalletControls";
import type {
  UseWalletWithEvmReturn,
  WalletControlsSubstrateProps,
} from "./types";

export function createWalletControls(
  SubstrateControls: FC<WalletControlsSubstrateProps>,
) {
  const WalletControls: FC<{ wallet: UseWalletWithEvmReturn }> = ({ wallet }) => {
    if (wallet.activeWalletKind === "evm") {
      return (
        <EvmWalletControls
          accounts={wallet.evmAccounts}
          selectedAddress={wallet.selectedAddress}
          onConnectClick={wallet.connectEvm}
          onAccountChange={wallet.selectEvmAccount}
          onDisconnect={wallet.disconnectEvm}
        />
      );
    }

    return (
      <SubstrateControls
        extensionNames={wallet.extensionNames}
        selectedExtensionName={wallet.selectedExtensionName}
        accounts={wallet.accounts}
        selectedAddress={wallet.selectedAddress}
        onConnectClick={() => {
          void wallet.discoverExtensions();
        }}
        onExtensionChange={(name) => {
          void wallet.selectExtension(name);
        }}
        onAccountChange={wallet.selectAccountByAddress}
      />
    );
  };

  return WalletControls;
}
