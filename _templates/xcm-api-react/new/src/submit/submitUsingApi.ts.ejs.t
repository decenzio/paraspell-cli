---
to: src/submit/submitUsingApi.ts
---
import axios from "axios";
import { Binary } from "polkadot-api";
import type { PolkadotSigner } from "polkadot-api";
import { createWsClient } from "polkadot-api/ws";
import { API_URL } from "../consts";
import { fetchFromApi<% if (evm) { %>, fetchFromEvmApi<% } %> } from "../fetchFromApi";
<% if (evm) { %>
import { isChainEvm } from "../evm";
import { submitEvmTx } from "./submitEvmTx";
import type { WalletSubmitOptions } from "../wallet/shared/types";
<% } %>
import { submitTransaction } from "../utils";
import type { ApiParams, ApiTransaction, FormValues } from "../types";

const submitApiTransaction = async (
  apiTx: ApiTransaction,
  signer: PolkadotSigner,
) => {
  const response = await axios.get(
    `${API_URL}/chains/${apiTx.chain}/ws-endpoints`,
  );
  const endpoints = response.data as string[];
  if (endpoints.length === 0) {
    throw new Error(`No WS endpoints found for chain ${apiTx.chain}`);
  }

  const client = createWsClient(endpoints[0]);
  try {
    const callData = Binary.fromHex(apiTx.tx);
    const tx = await client.getUnsafeApi().txFromCallData(callData);
    await submitTransaction(tx, signer);
  } finally {
    client.destroy();
  }
};

<% if (evm) { %>
export const submitUsingApi = async (
  formValues: FormValues,
  options: WalletSubmitOptions<PolkadotSigner>,
): Promise<void> => {
  if (isChainEvm(formValues.from)) {
    if (options.kind !== "evm") {
      throw new Error("EVM origin requires a connected EVM wallet.");
    }

    const sender = options.walletClient.account?.address;
    if (!sender) {
      throw new Error("EVM wallet has no connected account.");
    }

    const apiParams: ApiParams = {
      from: formValues.from,
      to: formValues.to,
      recipient: formValues.recipient,
      sender,
      currency: {
        location: formValues.currency!.location,
        amount: formValues.amount,
      },<% if (swap) { %>
      ...(formValues.swapEnabled && formValues.currencyTo
        ? {
            swapOptions: {
              currencyTo: { symbol: formValues.currencyTo },
              ...(formValues.exchange
                ? { exchange: [formValues.exchange] }
                : {}),
            },
          }
        : {}),<% } %>
    };

    const serializedTx = await fetchFromEvmApi(apiParams);
    await submitEvmTx(serializedTx, options.walletClient);
    return;
  }

  if (options.kind !== "substrate") {
    throw new Error("Substrate origin requires a Polkadot extension wallet.");
  }

  const apiParams: ApiParams = {
    from: formValues.from,
    to: formValues.to,
    recipient: formValues.recipient,
    sender: options.senderAddress,
    currency: {
      location: formValues.currency!.location,
      amount: formValues.amount,
    },<% if (swap) { %>
    ...(formValues.swapEnabled && formValues.currencyTo
      ? {
          swapOptions: {
            currencyTo: { symbol: formValues.currencyTo },
            ...(formValues.exchange
              ? { exchange: [formValues.exchange] }
              : {}),
          },
        }
      : {}),<% } %>
  };

  const transactions = await fetchFromApi(apiParams);

  for (const apiTx of transactions) {
    await submitApiTransaction(apiTx, options.signer);
  }
};
<% } else { %>
export const submitUsingApi = async (
  formValues: FormValues,
  signer: PolkadotSigner,
  senderAddress: string,
): Promise<void> => {
  const apiParams: ApiParams = {
    from: formValues.from,
    to: formValues.to,
    recipient: formValues.recipient,
    sender: senderAddress,
    currency: {
      location: formValues.currency!.location,
      amount: formValues.amount,
    },<% if (swap) { %>
    ...(formValues.swapEnabled && formValues.currencyTo
      ? {
          swapOptions: {
            currencyTo: { symbol: formValues.currencyTo },
            ...(formValues.exchange
              ? { exchange: [formValues.exchange] }
              : {}),
          },
        }
      : {}),<% } %>
  };

  const transactions = await fetchFromApi(apiParams);

  for (const apiTx of transactions) {
    await submitApiTransaction(apiTx, signer);
  }
};
<% } %>
