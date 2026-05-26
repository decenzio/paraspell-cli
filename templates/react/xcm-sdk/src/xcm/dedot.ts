import { UnsupportedOperationError, type TSubstrateChain } from "@paraspell/sdk";
import {
  Builder,
  createChainClient,
  type TDedotExtrinsic,
} from "@paraspell/sdk-dedot";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../types";

/* EVM_FEATURE */
import { isChainEvm } from "../evm";
/* END_EVM_FEATURE */

export async function buildTransactions(
  formValues: FormValues,
  senderAddress: string,
): Promise<TDedotExtrinsic[]> {

  /* GET_FORM_VALUES */
  const { from, to, recipient, amount, /* SWAP FEATURE */ swapEnabled /* END SWAP FEATURE */, currencyTo, exchange } =
    formValues;

  /* EVM_FEATURE */
  if (isChainEvm(from)) {
    throw new UnsupportedOperationError(
      "EVM origins are submitted via the EVM wallet path.",
    );
  }
  /* END_EVM_FEATURE */

  const substrateFrom = from as TSubstrateChain;
  const client = await createChainClient(substrateFrom);


  /* SWAP_FEATURE */
  if (swapEnabled) {
    const builder = Builder(client)
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
  /* END SWAP FEATURE */

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
  try {
    await tx.signAndSend(senderAddress, { signer }).untilFinalized();
  } catch (error) {
    throw error instanceof Error
      ? error
      : new UnsupportedOperationError(String(error));
  }
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
