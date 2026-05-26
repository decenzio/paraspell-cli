---
to: src/wallet/evm/index.ts
skip_if: <%= (!evm).toString() %>
---
/* EVM_FEATURE — entire file (barrel for EVM wallet UI + hook) */

export { WalletKindSelector } from "./WalletKindSelector";
export type { WalletKind, WalletKindSelectorProps } from "./WalletKindSelector";
export { EvmWalletControls } from "./EvmWalletControls";
export type { EvmWalletControlsProps } from "./EvmWalletControls";
export type { EvmAccountOption } from "./useEvmWallet";
