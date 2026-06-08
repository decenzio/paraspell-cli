import type { TSymbolSpecifier, TChain, TDestination } from "@paraspell/sdk";

export type TransferParams = {
  from: TChain;
  to: TDestination;
  amount: string;
  currencySymbol: string | TSymbolSpecifier;
  sender: string;
  recipient: string;
};
