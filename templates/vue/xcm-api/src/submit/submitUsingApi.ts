import axios from "axios";
import { Binary } from "polkadot-api";
import type { PolkadotSigner } from "polkadot-api";
import { createWsClient } from "polkadot-api/ws";
import { API_URL } from "../consts";
import { fetchFromApi } from "../fetchFromApi";
import { submitTransaction } from "../utils";
import type { ApiTransaction, FormValues } from "../types";

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
  const callData = Binary.fromHex(apiTx.tx);
  const tx = await client.getUnsafeApi().txFromCallData(callData);
  await submitTransaction(tx, signer);
};

export const submitUsingApi = async (
  formValues: FormValues,
  signer: PolkadotSigner,
  senderAddress: string,
): Promise<void> => {
  const apiParams = {
    from: formValues.from,
    to: formValues.to,
    recipient: formValues.recipient,
    sender: senderAddress,
    currency: {
      location: formValues.currency!.location,
      amount: formValues.amount,
    },
    /* SWAP_FEATURE */
    ...(formValues.swapEnabled && formValues.currencyTo
      ? {
          swapOptions: {
            currencyTo: { symbol: formValues.currencyTo },
            ...(formValues.exchange
              ? { exchange: [formValues.exchange] }
              : {}),
          },
        }
      : {}),
    /* END_SWAP_FEATURE */
  };

  const transactions = await fetchFromApi(apiParams);

  for (const apiTx of transactions) {
    await submitApiTransaction(apiTx, signer);
  }
};
