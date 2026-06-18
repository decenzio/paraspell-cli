import {
  Builder,
  type TPapiTransaction,
  UnsupportedOperationError,<% if (evmWallet) { %>
  isChainEvm,<% } %><% if (evm) { %>
<% } %>
} from "@paraspell/sdk";
import {
  InvalidTxError,
  type PolkadotSigner,
  type TxFinalizedPayload,
} from "polkadot-api";
import type { FormValues<% if (evmWallet) { %>, SubmitOptions<% } %> } from "../types";
import { requireCurrency<% if (swap) { %>, requireSwapCurrencyTo<% } %> } from "../requireAsset";<% if (evm) { %>
import "@paraspell/evm";<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %><% if (evmWallet) { %>
import { assertSubstrateOrigin } from "../evm/isEvmOrigin";
import { submitEvmTransferFromForm } from "./evmTransfer";
<% } -%>

export const submitUsingSdk = async (
  formValues: FormValues,
  <% if (evmWallet) { %>options: SubmitOptions,<% } else { %>signer: PolkadotSigner,
  senderAddress: string,<% } %>
): Promise<void> => {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;

<% if (evmWallet) { %>  if (isChainEvm(from)) {
    if (options.kind !== "evm") {
      throw new UnsupportedOperationError(
        "EVM origin requires a connected EVM wallet.",
      );
    }

    await submitEvmTransferFromForm(
      formValues,
      options.walletClient,
      options.provider,
    );
    return;
  }

  if (options.kind !== "substrate") {
    throw new UnsupportedOperationError(
      "Substrate origin requires a Polkadot extension wallet.",
    );
  }

  const { signer, senderAddress } = options;
<% } %><% if (evmWallet) { %>
  assertSubstrateOrigin(from);
<% } %>
  const currency = requireCurrency(formValues.currency);

<% if (swap) { %>  if (swapEnabled) {
    const resolvedCurrencyTo = requireSwapCurrencyTo(swapEnabled, currencyTo);
    if (!resolvedCurrencyTo) {
      throw new UnsupportedOperationError("Swap destination currency is required.");
    }
    const contexts = await Builder()
      .from(from)
      .to(to)
      .currency({ location: currency.location, amount })
      .recipient(recipient)
      .swap({
        currencyTo: { location: resolvedCurrencyTo.location },
        ...(exchange ? { exchange: [exchange] } : {}),
      })
      .sender(senderAddress)
      .buildAll();

    for (const ctx of contexts) {
      await submitPapiTransaction(ctx.tx, signer);
    }
    return;
  }

<% } %>  const tx = await Builder()
    .from(from)
    .to(to)
    .currency({ location: currency.location, amount })
    .recipient(recipient)
    .sender(senderAddress)
    .build();

  await submitPapiTransaction(tx, signer);
};

export const submitPapiTransaction = async (
  tx: TPapiTransaction,
  signer: PolkadotSigner,
  onSign?: () => void,
): Promise<TxFinalizedPayload> => {
  return new Promise((resolve, reject) => {
    tx.signSubmitAndWatch(signer).subscribe({
      next: (event) => {
        if (event.type === "signed") {
          onSign?.();
        }

        if (event.type === "finalized") {
          if (!event.ok) {
            const errorMsg = event.dispatchError?.value
              ? JSON.stringify(event.dispatchError.value)
              : "Transaction failed";
            reject(new UnsupportedOperationError(errorMsg));
          } else {
            resolve(event);
          }
        }
      },
      error: (error) => {
        if (error instanceof InvalidTxError) {
          reject(
            new UnsupportedOperationError(
              `Invalid transaction: ${JSON.stringify(error.error)}`,
            ),
          );
        } else {
          reject(error);
        }
      },
    });
  });
};
