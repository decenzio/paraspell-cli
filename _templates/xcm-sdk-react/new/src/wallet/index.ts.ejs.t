---
to: src/wallet/<%= clientDir %>/index.ts
---
<% if (evmWallet) { %>export {
  useWalletWithEvm as useWallet,
  WalletControls,
  type UseWalletReturn,
} from "./useWalletWithEvm";
export { WalletKindSelector } from "../evm/WalletKindSelector";
export type { WalletKind, WalletKindSelectorProps } from "../evm/WalletKindSelector";
<% } else if (client === 'pjs') { %>export { usePjsWallet } from "./usePjsWallet";
export { PjsWalletControls } from "./PjsWalletControls";
<% } else if (client === 'papi') { %>export { usePapiWallet } from "./usePapiWallet";
export { PapiWalletControls } from "./PapiWalletControls";
<% } else { %>export { useDedotWallet } from "./useDedotWallet";
export { DedotWalletControls } from "./DedotWalletControls";
<% } %>
