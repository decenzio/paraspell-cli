import { UnsupportedOperationError } from "@paraspell/sdk";
import {
  Builder,
  createChainClient,
  type Extrinsic,
} from "@paraspell/sdk-pjs";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../types";

export async function buildTransaction(
  formValues: FormValues,
  senderAddress: string,
): Promise<Extrinsic[]> {

  /* GET_FORM_VALUES */
  const { from, to, recipient, amount, swapEnabled, currencyTo, exchange } =
    formValues;

  const api = await createChainClient(from);

    /* SWAP_FEATURE */
  if (swapEnabled) {
    const builder = Builder(api)
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

  const tx = await Builder(api)
    .from(from)
    .to(to)
    .currency({ location: formValues.currency!.location, amount })
    .recipient(recipient)
    .sender(senderAddress)
    .build();

  return [tx];
}

async function submitTransaction(
  tx: Extrinsic,
  senderAddress: string,
  signer: Signer,
): Promise<void> {
  await tx.signAsync(senderAddress, { signer });

  await new Promise<void>((resolve, reject) => {
    void tx
      .send((result) => {
        if (!result.status.isFinalized) {
          return;
        }

        const { dispatchError } = result;

        if (dispatchError) {
          if (dispatchError.isModule) {
            const { docs, name, section } = tx.registry.findMetaError(
              dispatchError.asModule,
            );
            reject(
              new UnsupportedOperationError(
                `${section}.${name}: ${docs.join(" ")}`,
              ),
            );
          } else {
            reject(new UnsupportedOperationError(dispatchError.toString()));
          }
          return;
        }

        resolve();
      })
      .catch((error: unknown) => {
        reject(
          error instanceof Error
            ? error
            : new UnsupportedOperationError(String(error)),
        );
      });
  });
}


export const submitUsingSdk = async (
  formValues: FormValues,
  signer: Signer,
  senderAddress: string,
): Promise<void> => {
  if (!senderAddress) {
    alert("No account selected, connect wallet first");
    return;
  }

  const txs = await buildTransaction(formValues, senderAddress);
  for (const tx of txs) {
    await submitTransaction(tx, senderAddress, signer);
  }
};
