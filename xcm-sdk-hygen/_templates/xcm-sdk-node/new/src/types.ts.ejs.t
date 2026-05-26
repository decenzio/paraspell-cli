---
to: src/types.ts
---
import type { TChain, TSubstrateChain } from "@paraspell/sdk";<% if (swap) { %>
import type { TExchangeChain } from "@paraspell/sdk";<% } %>

export type TransferParams = {
  from: TChain;
  to: TChain;
  amount: string;
  currencySymbol: string;
  sender: string;
  recipient: string;<% if (swap) { %>
  currencyToSymbol?: string;
  exchange?: TExchangeChain;<% } %>
};

export type SubstrateTransferParams = TransferParams & {
  from: TSubstrateChain;
};
