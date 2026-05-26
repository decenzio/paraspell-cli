export { usePapiWallet } from "./usePapiWallet";
export { PapiWalletControls } from "./PapiWalletControls";

/* EVM_FEATURE — use these exports instead of usePapiWallet / PapiWalletControls above */
export {
  useWalletWithEvm as useWallet,
  WalletControls,
  type UseWalletReturn,
} from "./useWalletWithEvm";
export { WalletKindSelector } from "../evm/WalletKindSelector";
export type { WalletKind, WalletKindSelectorProps } from "../evm/WalletKindSelector";
/* END_EVM_FEATURE */
