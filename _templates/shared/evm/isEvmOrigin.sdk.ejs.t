import {
  isChainEvm,
  type TChain,
  type TSubstrateChain,
} from "<%= sdkPackage %>";

export function isSubstrateOrigin(chain: TChain): chain is TSubstrateChain {
  return !isChainEvm(chain);
}

export function assertSubstrateOrigin(chain: TChain): asserts chain is TSubstrateChain {
  if (!isSubstrateOrigin(chain)) {
    throw new Error("EVM origins are submitted via the EVM wallet path.");
  }
}
