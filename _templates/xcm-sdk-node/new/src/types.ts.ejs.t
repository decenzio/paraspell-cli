---
to: src/types.ts
---
import type { TSymbolSpecifier<% if (evm) { %>, TChain, TDestination<% } else { %>, TSubstrateChain<% } %> } from "@paraspell/sdk";<% if (swap) { %>
import type { TExchangeChain } from "@paraspell/sdk";<% } %>

export type TransferParams = {
  from: <% if (evm) { %>TChain<% } else { %>TSubstrateChain<% } %>;
  to: <% if (evm) { %>TDestination<% } else { %>TSubstrateChain<% } %>;
  amount: string;
  currencySymbol: string | TSymbolSpecifier;
  sender: string;
  recipient: string;<% if (swap) { %>
  currencyToSymbol?: string | TSymbolSpecifier;
  exchange?: TExchangeChain;<% } %>
};
