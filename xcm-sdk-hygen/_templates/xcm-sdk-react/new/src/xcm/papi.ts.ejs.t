---
to: src/xcm/papi.ts
skip_if: <%= (client !== 'papi').toString() %>
---
import {
  Builder,
  type TSubstrateChain,
  type TPapiTransaction,
  UnsupportedOperationError,
} from "@paraspell/sdk";
import {
  InvalidTxError,
  type PolkadotSigner,
  type TxFinalizedPayload,
} from "polkadot-api";
import type { FormValues } from "../types";<% if (evm) { %>
import "@paraspell/evm";<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %><% if (evm) { %>
import { isChainEvm } from "../evm";
import type { WalletClient } from "viem";
import { submitEvmTransferFromForm } from "./evmTransfer";

export type SubmitOptions =
  | { kind: "substrate"; signer: PolkadotSigner; senderAddress: string }
  | { kind: "evm"; walletClient: WalletClient };
<% } %>

export const submitUsingSdk = async (
  formValues: FormValues,
  <% if (evm) { %>options: SubmitOptions,<% } else { %>signer: PolkadotSigner,
  senderAddress: string,<% } %>
): Promise<void> => {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;

<% if (evm) { %>  if (isChainEvm(from)) {
    if (options.kind !== "evm") {
      throw new UnsupportedOperationError(
        "EVM origin requires a connected EVM wallet.",
      );
    }

<% if (swap) { %>    if (swapEnabled) {
      throw new UnsupportedOperationError(
        "Swap from EVM origins is not supported in this template.",
      );
    }

<% } %>    await submitEvmTransferFromForm(formValues, options.walletClient);
    return;
  }

  if (options.kind !== "substrate") {
    throw new UnsupportedOperationError(
      "Substrate origin requires a Polkadot extension wallet.",
    );
  }

  const { signer, senderAddress } = options;
<% } %>  const substrateFrom = from as TSubstrateChain;

<% if (swap) { %>  if (swapEnabled) {
    const contexts = await Builder()
      .from(substrateFrom)
      .to(to)
      .currency({ location: formValues.currency!.location, amount })
      .recipient(recipient)
      .swap({
        currencyTo: { location: currencyTo!.location },
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
    .from(substrateFrom)
    .to(to)
    .currency({ location: formValues.currency!.location, amount })
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
