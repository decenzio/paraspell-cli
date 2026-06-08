import { Builder } from "<%= sdkPackage %>";
import type { WalletClient } from "viem";
import type { FormValues } from "../types";
import { ensureEvmWalletClient, isChainEvm, toSdkEvmFrom } from "../evm";
import "@paraspell/evm";
<% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";
<% } %>

export const submitEvmTransferFromForm = async (
  formValues: FormValues,
  walletClient: WalletClient,
): Promise<void> => {
  const { from, to, recipient, amount } = formValues;
  const currency = {
    location: formValues.currency!.location,
    amount,
  };

  if (!isChainEvm(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }
  const signer = await ensureEvmWalletClient(walletClient, from);

  await Builder()
    .from(toSdkEvmFrom(from))
    .to(to)
    .currency(currency)
    .recipient(recipient)
    .sender(signer)
    .signAndSubmit();
};
