---
to: src/evm/index.ts
skip_if: <%= (!evm).toString() %>
---
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
