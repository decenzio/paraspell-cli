---
to: src/index.ts
---
import axios from "axios";
import { API_URL } from "./consts.js";
import { fetchFromApi } from "./fetchFromApi.js";
import { submitSubstrateTransfers } from "./submitSubstrate.js";
import type { TAssetInfo } from "@paraspell/sdk";
import type { TransferParams } from "./types.js";
<% if (evm) { %>
import { Native } from "@paraspell/sdk";
import { isChainEvm, submitEvmTransfer } from "./evm.js";
<% } %>

const defaults: TransferParams = {
  from: "<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'AssetHubPolkadot' %>",
  to: "Hydration",
  amount: "0.1",
  currencySymbol: <%= evm ? (snowbridge ? 'Native("ETH")' : 'Native("GLMR")') : '"DOT"' %>,
  sender: "<%= evm ? '0x0000000000000000000000000000000000000000' : '//Alice' %>",
  recipient: "5F5586mfsnM6durWRLptYt3jSUs55KEmahdodQ5tQMr9iY96",<% if (swap) { %>
  currencyToSymbol: "USDC",<% } %>
};

async function resolveCurrencyLocation(
  symbol: TransferParams["currencySymbol"],
  origin: string,
  destination: string,
): Promise<object> {
  const symbolValue = typeof symbol === "string" ? symbol : symbol.value;
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
}

async function transferViaApi(
  params: TransferParams,
): Promise<string | string[]> {
<% if (evm) { %>
  if (isChainEvm(params.from)) {
    return await submitEvmTransfer(params);
  }
<% } %>

  const location = await resolveCurrencyLocation(
    params.currencySymbol,
    params.from,
    params.to,
  );

  const apiParams = {
    from: params.from,
    to: params.to,
    recipient: params.recipient,
    sender: params.sender,
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

const result = await transferViaApi(defaults);

if (Array.isArray(result)) {
  console.log("Submitted XCM transfer(s):", result.join(", "));
} else {
  console.log("Submitted XCM transfer:", result);
}
