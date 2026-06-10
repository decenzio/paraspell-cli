---
to: src/types.ts
---
export type AssetInfo = {
  symbol?: string;
  assetId?: string;
  location: object;
};

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
  currency:
    | { location: object; amount: string }
    | { symbol: string; amount: string };
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
