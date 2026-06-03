---
to: src/wallet/evm/index.ts
skip_if: <%= (!evm).toString() %>
---
export { useEvmWallet } from "./useEvmWallet";
export { default as EvmWalletControls } from "./EvmWalletControls.vue";
export {
  default as WalletKindSelector,
  type WalletKind,
} from "./WalletKindSelector.vue";
