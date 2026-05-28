---
to: src/evm/index.ts
skip_if: <%= (!evm).toString() %>
---
/* EVM_FEATURE — entire file */

export {
  createEvmWalletClient,
  ensureEvmWalletClient,
  filterChainsForWallet,
  getEthereumProvider,
  getOriginChainsForWallet,
  isChainEvm,
  switchWalletToOrigin,
  toSdkEvmFrom,
} from "./evmWalletClient";
export type { EvmChain } from "./evmWalletClient";
