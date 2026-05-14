import type { TAssetInfo, TChain, TExchangeInput } from "@paraspell/sdk";
import { getSupportedAssets } from "@paraspell/sdk";
/* SWAP FEATURE */
import {
  getSupportedAssetsFrom,
  getSupportedAssetsTo,
} from "@paraspell/swap";
/* END SWAP FEATURE */
import { useMemo } from "react";

// Custom hook to get currency options based on the selected chains
// This way we can directly get the supported assets for the selected chains
const useCurrencyOptions = (
  from: TChain,
  to: TChain,
  /* SWAP FEATURE */
  swapEnabled: boolean,
  /* END SWAP FEATURE */
  exchange?: TExchangeInput
) => {
  /* SWAP FEATURE */
  // Get supported assets for the selected chains using the SDK
  const supportedAssets = useMemo(
    () =>
      swapEnabled
        ? getSupportedAssetsFrom(from, exchange)
        : getSupportedAssets(from, to),
    [from, to, swapEnabled, exchange]
  );

  // Get supported destination assets for swap mode
  const supportedAssetsTo = useMemo(
    () => (swapEnabled ? getSupportedAssetsTo(exchange, to) : []),
    [swapEnabled, exchange, to]
  );
  /* END SWAP FEATURE */

  // Create a map of supported assets for easy access
  const currencyMap = useMemo(
    () =>
      supportedAssets.reduce(
        (map: Record<string, TAssetInfo>, asset: TAssetInfo) => {
          const key = `${asset.symbol ?? "NO_SYMBOL"}-${
            ("assetId" in asset
              ? asset.assetId
              : JSON.stringify(asset?.location)) ?? "NO_ID"
          }`;
          map[key] = asset;
          return map;
        },
        {},
      ),
    [supportedAssets]
  );

  // Create options for the currency select dropdown
  const currencyOptions = useMemo(
    () =>
      Object.keys(currencyMap).map((key) => ({
        value: key,
        label: `${currencyMap[key].symbol} - ${
          ("assetId" in currencyMap[key]
            ? currencyMap[key].assetId
            : "Location") ?? "Native"
        }`,
      })),
    [currencyMap]
  );

  /* SWAP FEATURE */
  // Create a map of supported destination assets for swap
  const currencyToMap = useMemo(
    () =>
      supportedAssetsTo.reduce(
        (map: Record<string, TAssetInfo>, asset: TAssetInfo) => {
        const key = `${asset.symbol ?? "NO_SYMBOL"}-${
          ("assetId" in asset
            ? asset.assetId
            : JSON.stringify(asset?.location)) ?? "NO_ID"
        }`;
        map[key] = asset;
        return map;
      }, {}),
    [supportedAssetsTo]
  );

  // Create options for the destination currency select dropdown (swap)
  const currencyToOptions = useMemo(
    () =>
      Object.keys(currencyToMap).map((key) => ({
        value: key,
        label: `${currencyToMap[key].symbol} - ${
          ("assetId" in currencyToMap[key]
            ? currencyToMap[key].assetId
            : "Location") ?? "Native"
        }`,
      })),
    [currencyToMap]
  );
  /* END SWAP FEATURE */

  return {
    currencyOptions,
    currencyMap,
    /* SWAP FEATURE */
    currencyToOptions,
    currencyToMap
    /* END SWAP FEATURE */
  };
};

export default useCurrencyOptions;
