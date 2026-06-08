<% if (evm) { %>import { UnsupportedOperationError, type TSubstrateChain } from "@paraspell/sdk";
<% } %>
import {
  Builder,
  createChainClient,
  type TDedotExtrinsic,
} from "@paraspell/sdk-dedot";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../types";<% if (evm) { %>
import "@paraspell/evm";
import { isChainEvm } from "../evm";<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %>

export async function buildTransactions(
  formValues: FormValues,
  senderAddress: string,
): Promise<TDedotExtrinsic[]> {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;

<% if (evm) { %>  if (isChainEvm(from)) {
    throw new UnsupportedOperationError(
      "EVM origins are submitted via the EVM wallet path.",
    );
  }

<% } %>  const substrateFrom = from<% if (evm) { %> as TSubstrateChain<% } %>;

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

    return contexts.map((ctx) => ctx.tx);
  }

<% } %>  const client = await createChainClient(substrateFrom);
  const tx = await Builder(client)
    .from(substrateFrom)
    .to(to)
    .currency({ location: formValues.currency!.location, amount })
    .recipient(recipient)
    .sender(senderAddress)
    .build();

  return [tx];
}

async function submitTransaction(
  tx: TDedotExtrinsic,
  senderAddress: string,
  signer: Signer,
): Promise<void> {
  await tx.signAndSend(senderAddress, { signer }).untilFinalized();
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

  const txs = await buildTransactions(formValues, senderAddress);

  for (const tx of txs) {
    await submitTransaction(tx, senderAddress, signer);
  }
};
