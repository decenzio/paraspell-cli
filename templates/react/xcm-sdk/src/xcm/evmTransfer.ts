/* EVM_FEATURE — XCM submit for EVM parachain origins (Moonbeam, Moonriver, Darwinia, …) */

import { Builder } from "@paraspell/sdk-pjs";
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
  const currency = {
    location: formValues.currency!.location,
    amount,
  };

  if (!isChainEvm(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }

  await Builder()
    .from(toSdkEvmFrom(from))
    .to(to)
    .currency(currency)
    .recipient(recipient)
    .sender(signer)
    .signAndSubmit();
};
