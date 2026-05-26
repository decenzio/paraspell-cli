import type {
  TAssetInfo,
  TChain,
  TSubstrateChain,
  TExchangeChain,
} from "@paraspell/sdk";

export type FormValues = {
  from: TChain;
  to: TChain;
  currencyOptionId: string;
  recipient: string;
  amount: string;
  currency: TAssetInfo;
  swapEnabled?: boolean;
  currencyTo?: TAssetInfo;
  exchange?: TExchangeChain;
};
