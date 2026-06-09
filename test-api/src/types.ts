import type {
  TAssetInfo,
  TChain,
  TDestination,
  TSymbolSpecifier,
} from "@paraspell/sdk";

export type TransferParams = {
  from: TChain;
  to: TDestination;
  amount: string;
  currencySymbol: string | TSymbolSpecifier;
  recipient: string;
  currencyToSymbol?: string | TSymbolSpecifier;
  exchange?: string;
};

export type ApiParams = {
  from?: TChain;
  to?: TDestination;
  currency: {
    location: TAssetInfo["location"];
    amount: string;
  };
  recipient: string;
  sender: string;
  swapOptions?: {
    currencyTo: { symbol: string | TSymbolSpecifier };
    exchange?: string[];
  };
};

export type ApiTransaction = {
  type: string;
  chain: string;
  tx: string;
};
