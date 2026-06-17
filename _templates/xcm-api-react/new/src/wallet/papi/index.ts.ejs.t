---
to: src/wallet/papi/index.ts
---
export { usePapiWallet } from "./usePapiWallet";
export { PapiWalletControls } from "./PapiWalletControls";
<% if (evmWallet) { %>
export {
  useWalletWithEvm as useWallet,
  WalletControls,
  type UseWalletReturn,
} from "./useWalletWithEvm";
export { WalletKindSelector } from "../evm/WalletKindSelector";
export type { WalletKind, WalletKindSelectorProps } from "../evm/WalletKindSelector";
<% } %>
