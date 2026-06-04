---
to: src/types.ts
---
<% if (evm) { %>import type { TAssetInfo } from "@paraspell/sdk";

<% } %>
<% if (evm) { %>export type AssetInfo = TAssetInfo;<% } else { %>
export type AssetInfo = {
  symbol?: string;
  assetId?: string;
  location: object;
};<% } %>

export type FormValues = {
  from: string;
  to: string;
  currency: AssetInfo;
  recipient: string;
  amount: string;<% if (swap) { %>
  swapEnabled?: boolean;
  currencyTo?: string;
  exchange?: string;<% } %>
};

export type ApiParams = {
  from?: string;
  to?: string;
  currency: {
    location: <% if (evm) { %>TAssetInfo["location"]<% } else { %>object<% } %>;
    amount: string;
  };
  recipient: string;
  sender: string;<% if (swap) { %>
  swapOptions?: {
    currencyTo: { symbol: string };
    exchange?: string[];
  };<% } %>
};

export type ApiTransaction = {
  type: string;
  chain: string;
  tx: string;
};
