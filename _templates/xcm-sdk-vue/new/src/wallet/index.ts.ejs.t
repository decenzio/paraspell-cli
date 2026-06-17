---
to: src/wallet/<%= clientDir %>/index.ts
---
<% if (evmWallet) { %>export {
  useWalletWithEvm as useWallet,
  WalletControls,
  type UseWalletReturn,
} from "./useWalletWithEvm";
export { WalletKindSelector } from "../evm";
export type { WalletKind } from "../evm";
<% } else if (client === 'pjs') { %>export { usePjsWallet } from "./usePjsWallet";
export { default as PjsWalletControls } from "./PjsWalletControls.vue";
<% } else if (client === 'papi') { %>export { usePapiWallet } from "./usePapiWallet";
export { default as PapiWalletControls } from "./PapiWalletControls.vue";
<% } else { %>export { useDedotWallet } from "./useDedotWallet";
export { default as DedotWalletControls } from "./DedotWalletControls.vue";
<% } %>
