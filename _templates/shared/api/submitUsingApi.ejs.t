import axios from "axios";
import { Binary } from "polkadot-api";
import type { PolkadotSigner } from "polkadot-api";
import { createWsClient } from "polkadot-api/ws";
import { API_URL } from "../consts";
import { fetchFromApi<% if (evmWallet) { %>, fetchFromEvmApi<% } %> } from "../fetchFromApi";
import { requireCurrency<% if (swap) { %>, requireSwapCurrencyTo<% } %> } from "../requireAsset";
<% if (evmWallet) { %>import { fetchEvmOriginChains, isEvmOrigin } from "../evm";
import { submitEvmTx } from "./submitEvmTx";
<% } %>import { submitTransaction } from "../utils";
import type {
  ApiParams,
  ApiTransaction,
  FormValues<% if (evmWallet) { %>,
  WalletSubmitOptions<% } %>,
} from "../types";

<%- h.includeShared('shared/api/buildApiParams.ejs.t') %>

const submitApiTransaction = async (
  apiTx: ApiTransaction,
  signer: PolkadotSigner,
) => {
  const response = await axios.get<string[]>(
    `${API_URL}/chains/${apiTx.chain}/ws-endpoints`,
  );
  const endpoints = response.data;

  const client = createWsClient(endpoints[0]);
  try {
    const callData = Binary.fromHex(apiTx.tx);
    const tx = await client.getUnsafeApi().txFromCallData(callData);
    await submitTransaction(tx, signer);
  } finally {
    client.destroy();
  }
};
<% if (evmWallet) { %>
export const submitUsingApi = async (
  formValues: FormValues,
  options: WalletSubmitOptions<PolkadotSigner>,
): Promise<void> => {
  const currency = requireCurrency(formValues.currency);
<% if (swap) { %>  const swapCurrencyTo = requireSwapCurrencyTo(
    formValues.swapEnabled,
    formValues.currencyTo,
  );
<% } %>

  await fetchEvmOriginChains();

  if (isEvmOrigin(formValues.from)) {
    if (options.kind !== "evm") {
      throw new Error("EVM origin requires a connected EVM wallet.");
    }

    const sender = options.walletClient.account?.address;
    if (!sender) {
      throw new Error("EVM wallet has no connected account.");
    }

    const serializedTx = await fetchFromEvmApi(
      buildApiParams(
        formValues.from,
        formValues.to,
        formValues.recipient,
        sender,
        formValues.amount,
        currency.location,<% if (swap) { %>
        formValues.swapEnabled && swapCurrencyTo
          ? swapCurrencyTo.location
          : undefined,
        formValues.exchange,<% } %>
      ),
    );
    await submitEvmTx(serializedTx, options.walletClient);
    return;
  }

  if (options.kind !== "substrate") {
    throw new Error("Substrate origin requires a Polkadot extension wallet.");
  }

  const transactions = await fetchFromApi(
    buildApiParams(
      formValues.from,
      formValues.to,
      formValues.recipient,
      options.senderAddress,
      formValues.amount,
      currency.location,<% if (swap) { %>
      formValues.swapEnabled && swapCurrencyTo
        ? swapCurrencyTo.location
        : undefined,
      formValues.exchange,<% } %>
    ),
  );

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
  const currency = requireCurrency(formValues.currency);
<% if (swap) { %>  const swapCurrencyTo = requireSwapCurrencyTo(
    formValues.swapEnabled,
    formValues.currencyTo,
  );
<% } %>

  const transactions = await fetchFromApi(
    buildApiParams(
      formValues.from,
      formValues.to,
      formValues.recipient,
      senderAddress,
      formValues.amount,
      currency.location,<% if (swap) { %>
      formValues.swapEnabled && swapCurrencyTo
        ? swapCurrencyTo.location
        : undefined,
      formValues.exchange,<% } %>
    ),
  );

  for (const apiTx of transactions) {
    await submitApiTransaction(apiTx, signer);
  }
};
<% } %>
