<% if (evm) { %>import {
  isChainEvm,
  type TChain,
  type TSubstrateChain,
} from "@paraspell/sdk";
<% } else { %>import { type TChain, type TSubstrateChain } from "@paraspell/sdk";
<% } %>
export function isEvmOrigin(chain: TChain): boolean {
<% if (evm) { %>  if (isChainEvm(chain)) {
    return true;
  }
<% } %><% if (snowbridge) { %>  if (chain === "Ethereum") {
    return true;
  }
<% } %>  return false;
}

export function isSubstrateOrigin(chain: TChain): chain is TSubstrateChain {
  return !isEvmOrigin(chain);
}

export function assertSubstrateOrigin(chain: TChain): asserts chain is TSubstrateChain {
  if (!isSubstrateOrigin(chain)) {
    throw new Error("EVM origins are submitted via the EVM wallet path.");
  }
}
