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
import type { FormValues } from "../types";

/* EVM_FEATURE */
import "@paraspell/evm";
import { isChainEvm } from "../evm";
/* END_EVM_FEATURE */

/* SNOWBRIDGE_FEATURE */
import "@paraspell/evm-snowbridge";
/* END_SNOWBRIDGE_FEATURE */
import type { WalletClient } from "viem";
import { submitEvmTransferFromForm } from "./evmTransfer";

export type SubmitOptions =
  | { kind: "substrate"; signer: PolkadotSigner; senderAddress: string }
  | { kind: "evm"; walletClient: WalletClient };
/* END_EVM_FEATURE */

export const submitUsingSdk = async (
  formValues: FormValues,
  options: SubmitOptions,
): Promise<void> => {
  /* GET_FORM_VALUES */
  const { from, to, recipient, amount, swapEnabled, currencyTo, exchange } =
    formValues;

  /* EVM_FEATURE */
  if (isChainEvm(from)) {
    if (options.kind !== "evm") {
      throw new UnsupportedOperationError(
        "EVM origin requires a connected MetaMask wallet.",
      );
    }

    /* SWAP_FEATURE */
    if (swapEnabled) {
      throw new UnsupportedOperationError(
        "Swap from EVM origins is not supported in this template.",
      );
    }
    /* END SWAP_FEATURE */

    await submitEvmTransferFromForm(formValues, options.walletClient);
    return;
  }

  if (options.kind !== "substrate") {
    throw new UnsupportedOperationError(
      "Substrate origin requires a Polkadot extension wallet.",
    );
  }
  /* END_EVM_FEATURE */

  const { signer, senderAddress } = options;
  const substrateFrom = from as TSubstrateChain;

  /* SWAP_FEATURE */
  if (swapEnabled) {
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
  /* END SWAP_FEATURE */

  const tx = await Builder()
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
      error: (error: unknown) => {
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
