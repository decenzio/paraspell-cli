import {
  Builder,
  type TPapiTransaction,
  UnsupportedOperationError,
} from "@paraspell/sdk";
import {
  InvalidTxError,
  type PolkadotSigner,
  type TxFinalizedPayload,
} from "polkadot-api";
import type { FormValues } from "../types";

export async function buildPapiTransactions(
  formValues: FormValues,
  senderAddress: string,
): Promise<TPapiTransaction[]> {
  const { from, to, recipient, amount, swapEnabled, currencyTo, exchange } =
    formValues;

  if (swapEnabled) {
    const builder = Builder()
      .from(from)
      .to(to)
      .currency({ location: formValues.currency!.location, amount })
      .recipient(recipient)
      .swap({
        currencyTo: { location: currencyTo!.location },
        ...(exchange ? { exchange: [exchange] } : {}),
      })
      .sender(senderAddress);

    const contexts = await builder.buildAll();
    return contexts.map((ctx) => ctx.tx);
  }

  const tx = await Builder()
    .from(from)
    .to(to)
    .currency({ location: formValues.currency!.location, amount })
    .recipient(recipient)
    .sender(senderAddress)
    .build();

  return [tx];
}

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
          const typedErr = error.error;
          reject(
            new UnsupportedOperationError(
              `Invalid transaction: ${JSON.stringify(typedErr)}`,
            ),
          );
        } else {
          reject(
            error instanceof Error
              ? error
              : new UnsupportedOperationError(String(error)),
          );
        }
      },
    });
  });
};

export const submitUsingSdk = async (
  formValues: FormValues,
  signer: PolkadotSigner,
  senderAddress: string,
): Promise<void> => {
  if (!senderAddress) {
    alert("No account selected, connect wallet first");
    return;
  }

  const txs = await buildPapiTransactions(formValues, senderAddress);
  for (const tx of txs) {
    await submitPapiTransaction(tx, signer);
  }
};
