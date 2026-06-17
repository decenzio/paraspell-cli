---
to: src/types.ts
---
import type { TChain, TLocation, TSubstrateChain } from "@paraspell/sdk";

export type TransferParams = {
  from: TChain;
  to: TChain;
  amount: string;
  currencyLocation?: TLocation;
  recipient: string;
  currencyToLocation?: TLocation;
};
