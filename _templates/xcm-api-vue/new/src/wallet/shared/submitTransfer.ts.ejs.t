---
to: src/wallet/shared/submitTransfer.ts
skip_if: <%= (!evm).toString() %>
---
import type { WalletKind } from "../evm/WalletKindSelector.vue";

export const connectWalletAlert = (wallet: {
  activeWalletKind: WalletKind;
}): void => {
  alert(
    wallet.activeWalletKind === "evm"
      ? "Connect EVM wallet provider first"
      : "No account selected, connect wallet first",
  );
};
