---
to: src/utils.ts
---
import {
  InvalidTxError,
  type PolkadotSigner,
  type TxFinalizedPayload,
} from "polkadot-api";

type SignableTx = {
  signSubmitAndWatch: (signer: PolkadotSigner) => {
    subscribe: (handlers: {
      next: (event: { type: string; ok?: boolean; dispatchError?: { value?: unknown }; txHash?: string }) => void;
      error: (error: Error) => void;
    }) => void;
  };
};

export const submitTransaction = async (
  tx: SignableTx,
  signer: PolkadotSigner,
  onSign?: () => void,
): Promise<TxFinalizedPayload | { txHash: string }> => {
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
            reject(new Error(errorMsg));
          } else {
            resolve(event as unknown as TxFinalizedPayload);
          }
        }
      },
      error: (error) => {
        if (error instanceof InvalidTxError) {
          reject(
            new Error(`Invalid transaction: ${JSON.stringify(error.error)}`),
          );
        } else {
          reject(error);
        }
      },
    });
  });
};
