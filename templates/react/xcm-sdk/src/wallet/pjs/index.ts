export { usePjsWallet } from "./usePjsWallet";
export { PjsWalletControls } from "./PjsWalletControls";

/* EVM_FEATURE — use these exports instead of usePjsWallet / PjsWalletControls above */
export {
  useWalletWithEvm as useWallet,
  WalletControls,
  type UseWalletReturn,
} from "./useWalletWithEvm";
export { WalletKindSelector } from "../evm/WalletKindSelector";
export type { WalletKind, WalletKindSelectorProps } from "../evm/WalletKindSelector";
/* END_EVM_FEATURE */
