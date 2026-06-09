---
to: src/transfer.ts
---
import axios from "axios";
import { API_URL } from "./consts.js";
import { fetchFromApi } from "./fetchFromApi.js";
import { submitSubstrateTransfers } from "./submitSubstrate.js";
import type { TAssetInfo } from "@paraspell/sdk";
import type { TransferParams } from "./types.js";
<% if (evm) { %>
<% if (!snowbridge) { %>import { Native } from "@paraspell/sdk";
<% } %>import { isChainEvm, submitEvmTransfer } from "./evm.js";
<% } %>
import { getSubstrateMnemonic, getSubstrateSenderAddress } from "./substrate.js";

const defaults: TransferParams = {
  from: "<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'Astar' %>",
  to: "Hydration",
  amount: "0.1",
<% if (snowbridge) { -%>
  currencySymbol: "ETH",
<% } else if (evm) { -%>
  currencySymbol: Native("GLMR"),
<% } else { -%>
  currencySymbol: "ASTR",
<% } -%>
  recipient: "//Bob",<% if (swap) { %>
  currencyToSymbol: "<%= evm ? 'USDC' : 'DOT' %>",<% } %>
};

type ApiErrorResponse = {
  message?: string;
};

async function resolveCurrencyLocation(
  symbol: TransferParams["currencySymbol"],
  origin: TransferParams["from"],
  destination: TransferParams["to"],
): Promise<TAssetInfo["location"]> {
  const symbolValue = typeof symbol === "string" ? symbol : symbol.value;
  try {
    const response = await axios.get(
      `${API_URL}/supported-assets?origin=${origin}&destination=${destination}`,
    );
    const assets = response.data as TAssetInfo[];
    const asset = assets.find((a) => a.symbol === symbolValue);
    if (!asset) {
      throw new Error(
        `Asset ${symbolValue} not found for ${origin} -> ${destination}`,
      );
    }
    return asset.location;
  } catch (error) {
    if (axios.isAxiosError<ApiErrorResponse>(error)) {
      const message = error.response?.data.message;
      const serverMessage = message ? ` Server response: ${message}` : "";
      throw new Error(`Error while resolving asset.${serverMessage}`, {
        cause: error,
      });
    }
    throw error;
  }
}

export async function transferViaApi(): Promise<string | string[]> {
  const params = defaults;
<% if (evm) { %>
  if (isChainEvm(params.from)) {
    return await submitEvmTransfer(params);
  }
<% } %>

  const mnemonic = getSubstrateMnemonic();
  const sender = await getSubstrateSenderAddress(mnemonic);

  const location = await resolveCurrencyLocation(
    params.currencySymbol,
    params.from,
    params.to,
  );

  const apiParams = {
    from: params.from,
    to: params.to,
    recipient: params.recipient,
    sender,
    currency: {
      location,
      amount: params.amount,
    },<% if (swap) { %>
    ...(params.currencyToSymbol
      ? {
          swapOptions: {
            currencyTo: { symbol: params.currencyToSymbol },
            ...(params.exchange ? { exchange: [params.exchange] } : {}),
          },
        }
      : {}),<% } %>
  };

  const transactions = await fetchFromApi(apiParams);
  return await submitSubstrateTransfers(transactions);
}
