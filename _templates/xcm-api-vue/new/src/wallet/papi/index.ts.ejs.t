---
to: src/wallet/papi/index.ts
---
export { usePapiWallet } from "./usePapiWallet";
export { default as PapiWalletControls } from "./PapiWalletControls.vue";
<% if (evmWallet) { %>
export {
  useWalletWithEvm as useWallet,
  WalletControls,
  type UseWalletReturn,
} from "./useWalletWithEvm";
export { default as WalletKindSelector } from "../evm/WalletKindSelector.vue";
export type { WalletKind } from "../evm/WalletKindSelector.vue";
<% } %>
