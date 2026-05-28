---
to: src/types.ts
---
import type { TChain, TSymbolSpecifier } from "@paraspell/sdk";<% if (swap) { %>
import type { TExchangeChain } from "@paraspell/sdk";<% } %>

export type TransferParams = {
  from: TChain;
  to: TChain;
  amount: string;
  currencySymbol: string | TSymbolSpecifier;
  sender: string;
  recipient: string;<% if (swap) { %>
  currencyToSymbol?: string | TSymbolSpecifier;
  exchange?: TExchangeChain;<% } %>
};
