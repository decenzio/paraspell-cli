import { UnsupportedOperationError, type TSubstrateChain } from "@paraspell/sdk";
import {
  Builder,
  createChainClient,
  type TDedotExtrinsic,
} from "@paraspell/sdk-dedot";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../types";

export async function buildTransactions(
  formValues: FormValues,
  senderAddress: string,
): Promise<TDedotExtrinsic[]> {
  const { from, to, recipient, amount } =
    formValues;

  const substrateFrom = from as TSubstrateChain;
  const client = await createChainClient(substrateFrom);

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
