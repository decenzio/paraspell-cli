---
to: src/types.ts
---
import type { TAssetInfo, TChain<% if (swap) { %>, TExchangeChain<% } %> } from "@paraspell/sdk";

export type FormValues = {
  from: TChain;
  to: TChain;
  currencyOptionId: string;
  recipient: string;
  amount: string;
  currency: TAssetInfo;<% if (swap) { %>
  swapEnabled?: boolean;
  currencyTo?: TAssetInfo;
  exchange?: TExchangeChain;<% } %>
};
