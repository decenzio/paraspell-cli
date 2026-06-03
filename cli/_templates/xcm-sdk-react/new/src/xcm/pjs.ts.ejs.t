---
to: src/xcm/pjs.ts
skip_if: <%= (client !== 'pjs').toString() %>
---
import { UnsupportedOperationError<% if (evm) { %>, type TSubstrateChain<% } %> } from "@paraspell/sdk";
import {
  Builder,
  createChainClient,
  type Extrinsic,
} from "@paraspell/sdk-pjs";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../types";<% if (evm) { %>
import "@paraspell/evm";
import { isChainEvm } from "../evm";<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %>

export async function buildTransaction(
  formValues: FormValues,
  senderAddress: string,
): Promise<Extrinsic[]> {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;

<% if (evm) { %>  if (isChainEvm(from)) {
    throw new UnsupportedOperationError(
      "EVM origins are submitted via the EVM wallet path.",
    );
  }

<% } %>  const substrateFrom = from<% if (evm) { %> as TSubstrateChain<% } %>;
  const api = await createChainClient(substrateFrom);

<% if (swap) { %>  if (swapEnabled) {
    const builder = Builder(api)
      .from(substrateFrom)
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

<% } %>  const tx = await Builder(api)
    .from(substrateFrom)
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
      .catch((error) => {
        reject(error);
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
