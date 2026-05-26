import type { TChain, TSubstrateChain } from "@paraspell/sdk";

export type TransferParams = {
  from: TChain;
  to: TChain;
  amount: string;
  currencySymbol: string;
  sender: string;
  recipient: string;
};

export type SubstrateTransferParams = TransferParams & {
  from: TSubstrateChain;
};
