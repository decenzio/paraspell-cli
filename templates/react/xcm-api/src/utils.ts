import {
  InvalidTxError,
  type PolkadotSigner,
  type TxFinalizedPayload,
} from "polkadot-api";

type SignableTx = {
  signSubmitAndWatch: (signer: PolkadotSigner) => {
    subscribe: (handlers: {
      next: (event: { type: string; ok?: boolean; dispatchError?: { value?: unknown }; txHash?: string }) => void;
      error: (error: unknown) => void;
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
      error: (error: unknown) => {
        if (error instanceof InvalidTxError) {
          const typedErr = error.error;
          reject(
            new Error(`Invalid transaction: ${JSON.stringify(typedErr)}`),
          );
        } else {
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      },
    });
  });
};
