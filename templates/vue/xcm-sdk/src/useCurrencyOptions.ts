import type { Ref } from "vue";
import { computed } from "vue";
import type { TAssetInfo, TChain, TExchangeInput } from "@paraspell/sdk";
import { getSupportedAssets } from "@paraspell/sdk";
import {
  getSupportedAssetsFrom,
  getSupportedAssetsTo,
} from "@paraspell/swap";

function assetKey(asset: TAssetInfo): string {
  return `${asset.symbol ?? "NO_SYMBOL"}-${
    ("assetId" in asset ? asset.assetId : JSON.stringify(asset?.location)) ??
    "NO_ID"
  }`;
}

export default function useCurrencyOptions(
  from: Ref<TChain>,
  to: Ref<TChain>,
  swapEnabled: Ref<boolean>,
  exchange: Ref<TExchangeInput | undefined>,
) {
  const supportedAssets = computed(() =>
    swapEnabled.value
      ? getSupportedAssetsFrom(from.value, exchange.value)
      : getSupportedAssets(from.value, to.value),
  );

  const supportedAssetsTo = computed(() =>
    swapEnabled.value ? getSupportedAssetsTo(exchange.value, to.value) : [],
  );

  const currencyMap = computed(() =>
    supportedAssets.value.reduce(
      (map: Record<string, TAssetInfo>, asset: TAssetInfo) => {
        map[assetKey(asset)] = asset;
        return map;
      },
      {},
    ),
  );

  const currencyOptions = computed(() =>
    Object.keys(currencyMap.value).map((key) => ({
      value: key,
      label: `${currencyMap.value[key].symbol} - ${
        ("assetId" in currencyMap.value[key]
          ? currencyMap.value[key].assetId
          : "Location") ?? "Native"
      }`,
    })),
  );

  const currencyToMap = computed(() =>
    supportedAssetsTo.value.reduce(
      (map: Record<string, TAssetInfo>, asset: TAssetInfo) => {
        map[assetKey(asset)] = asset;
        return map;
      },
      {},
    ),
  );

  const currencyToOptions = computed(() =>
    Object.keys(currencyToMap.value).map((key) => ({
      value: key,
      label: `${currencyToMap.value[key].symbol} - ${
        ("assetId" in currencyToMap.value[key]
          ? currencyToMap.value[key].assetId
          : "Location") ?? "Native"
      }`,
    })),
  );

  return { currencyOptions, currencyMap, currencyToOptions, currencyToMap };
}
