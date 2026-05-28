import type { TChain, TSymbolSpecifier } from "@paraspell/sdk";

export type TransferParams = {
  from: TChain;
  to: TChain;
  amount: string;
  currencySymbol: string | TSymbolSpecifier;
  sender: string;
  recipient: string;
};
