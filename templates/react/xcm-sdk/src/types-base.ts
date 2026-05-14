import type { TAssetInfo, TChain, TSubstrateChain } from "@paraspell/sdk";

export type FormValues = {
  from: TSubstrateChain;
  to: TChain;
  currencyOptionId: string;
  recipient: string;
  amount: string;
  currency: TAssetInfo;
};
