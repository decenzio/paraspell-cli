/* EVM_FEATURE — entire file */

export {
  createEvmWalletClient,
  ensureEvmWalletClient,
  getEthereumProvider,
  getOriginChainsForWallet,
  isChainEvm,
  switchWalletToOrigin,
  toSdkEvmFrom,
} from "./evmWalletClient";
export type { EvmChain } from "./evmWalletClient";
