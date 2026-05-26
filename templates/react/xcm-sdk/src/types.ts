import type { TAssetInfo, TChain, TExchangeChain } from "@paraspell/sdk";

export type FormValues = {
  from: TChain;
  to: TChain;
  currencyOptionId: string;
  recipient: string;
  amount: string;
  currency: TAssetInfo;
  /* SWAP FEATURE */
  swapEnabled?: boolean;
  currencyTo?: TAssetInfo;
  exchange?: TExchangeChain;
  /* END SWAP FEATURE */
};
