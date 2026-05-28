/* EVM_FEATURE — XCM submit for EVM origins (local Builder, not XCM API) */

import { Builder, type TChain } from "@paraspell/sdk";
import type { WalletClient } from "viem";
import type { FormValues } from "../types";
import { ensureEvmWalletClient, isChainEvm, toSdkEvmFrom } from "../evm";
import "@paraspell/evm";

/* SNOWBRIDGE_FEATURE */
import "@paraspell/evm-snowbridge";
/* END_SNOWBRIDGE_FEATURE */

export const submitEvmTransferFromForm = async (
  formValues: FormValues,
  walletClient: WalletClient,
): Promise<void> => {
  const { from, to, recipient, amount } = formValues;
  const signer = await ensureEvmWalletClient(walletClient, from);
  if (!isChainEvm(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }

  await Builder()
    .from(toSdkEvmFrom(from))
    .to(to as TChain)
    .currency({
      location: formValues.currency!.location as never,
      amount,
    })
    .recipient(recipient)
    .sender(signer)
    .signAndSubmit();
};
