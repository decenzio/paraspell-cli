export { useDedotWallet } from "./useDedotWallet";
export { DedotWalletControls } from "./DedotWalletControls";

/* EVM_FEATURE — use these exports instead of useDedotWallet / DedotWalletControls above */
export {
  useWalletWithEvm as useWallet,
  WalletControls,
  type UseWalletReturn,
} from "./useWalletWithEvm";
export { WalletKindSelector } from "../evm/WalletKindSelector";
export type { WalletKind, WalletKindSelectorProps } from "../evm/WalletKindSelector";
/* END_EVM_FEATURE */
