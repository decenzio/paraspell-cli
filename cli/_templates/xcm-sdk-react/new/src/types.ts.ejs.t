---
to: src/types.ts
---
import type { TAssetInfo<% if (evm) { %>, TChain<% } else { %>, TSubstrateChain<% } %><% if (swap) { %>, TExchangeChain<% } %> } from "@paraspell/sdk";

export type FormValues = {
  from: <% if (evm) { %>TChain<% } else { %>TSubstrateChain<% } %>;
  to: <% if (evm) { %>TChain<% } else { %>TSubstrateChain<% } %>;
  currencyOptionId: string;
  recipient: string;
  amount: string;
  currency: TAssetInfo;<% if (swap) { %>
  swapEnabled?: boolean;
  currencyTo?: TAssetInfo;
  exchange?: TExchangeChain;<% } %>
};
