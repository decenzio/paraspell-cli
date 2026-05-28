import type { TSymbolSpecifier } from "@paraspell/sdk";

export type TransferParams = {
  from: string;
  to: string;
  amount: string;
  currencySymbol: string | TSymbolSpecifier;
  sender: string;
  recipient: string;
  currencyToSymbol?: string | TSymbolSpecifier;
  exchange?: string;
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
