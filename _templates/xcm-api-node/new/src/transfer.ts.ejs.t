---
to: src/transfer.ts
---
import axios from "axios";
import { API_URL } from "./consts.js";
import { fetchFromApi<% if (evm) { %>, fetchFromEvmApi<% } %> } from "./fetchFromApi.js";
import { submitSubstrateTransfers } from "./submitSubstrate.js";
import type { AssetInfo, ApiParams, TransferParams } from "./types.js";
<% if (evm) { %>
import { getEvmSenderAddress, getEvmWalletClient, isChainEvm } from "./evm.js";
import { submitEvmTx } from "./submitEvmTx.js";
<% } %>
import { getSubstrateMnemonic, getSubstrateSenderAddress } from "./substrate.js";

const defaults: TransferParams = {
  from: "<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'Astar' %>",
  to: "Hydration",
  amount: "0.1",
  currencySymbol: "<%= snowbridge ? 'ETH' : evm ? 'GLMR' : 'ASTR' %>",
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
): Promise<AssetInfo["location"]> {
  try {
    const response = await axios.get(
      `${API_URL}/supported-assets?origin=${origin}&destination=${destination}`,
    );
    const assets = response.data as AssetInfo[];
    const asset = assets.find((a) => a.symbol === symbol);
    if (!asset) {
      throw new Error(
        `Asset ${symbol} not found for ${origin} -> ${destination}`,
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
    const sender = getEvmSenderAddress(params.from);
    const walletClient = getEvmWalletClient(params.from);
    const apiParams: ApiParams = {
      from: params.from,
      to: params.to,
      recipient: params.recipient,
      sender,
      currency: {
        symbol: params.currencySymbol,
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
    const serializedTx = await fetchFromEvmApi(apiParams);
    const txHash = await submitEvmTx(serializedTx, walletClient);
    return txHash;
  }
<% } -%>

  const mnemonic = getSubstrateMnemonic();
  const sender = await getSubstrateSenderAddress(mnemonic);

  const location = await resolveCurrencyLocation(
    params.currencySymbol,
    params.from,
    params.to,
  );

  const apiParams: ApiParams = {
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
