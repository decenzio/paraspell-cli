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
  amount: string;
  originWsUrl?: string;
  /* SWAP_FEATURE */
  swapEnabled?: boolean;
  currencyTo?: string;
  exchange?: string;
  /* END_SWAP_FEATURE */
};

export type ApiParams = {
  from?: string;
  to?: string;
  currency: {
    location: object;
    amount: string;
  };
  recipient: string;
  sender: string;
  /* SWAP_FEATURE */
  swapOptions?: {
    currencyTo: { symbol: string };
    exchange?: string[];
  };
  /* END_SWAP_FEATURE */
};

export type ApiTransaction = {
  type: string;
  chain: string;
  tx: string;
};
