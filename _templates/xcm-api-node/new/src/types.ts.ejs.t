---
to: src/types.ts
---
export type AssetInfo = {
  symbol?: string;
  assetId?: string;
  location: object;
};

export type TransferParams = {
  from: string;
  to: string;
  amount: string;
  currencySymbol: string;
  recipient: string;
  currencyToSymbol?: string;
  exchange?: string;
};

export type ApiParams = {
  from?: string;
  to?: string;
  currency:
    | { location: object; amount: string }
    | { symbol: string; amount: string };
  recipient: string;
  sender: string;
  swapOptions?: {
    currencyTo: { symbol: string };
    exchange?: string[];
  };
};

export type ApiTransaction = {
  type: string;
  chain: string;
  tx: string;
};
