import { Builder } from "<%= sdkPackage %>";
import type { WalletClient } from "viem";
import type { FormValues } from "../types";
import { ensureEvmWalletClient, isChainEvm, toSdkEvmFrom } from "../evm/evmWalletClient";
import "@paraspell/evm";
<% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";
<% } %><% if (swap) { %>
import "@paraspell/swap";
<% } -%>

export const submitEvmTransferFromForm = async (
  formValues: FormValues,
  walletClient: WalletClient,
): Promise<void> => {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;
  const currency = {
    location: formValues.currency!.location,
    amount,
  };

  if (!isChainEvm(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }
  const signer = await ensureEvmWalletClient(walletClient, from);

<% if (swap) { %>  if (swapEnabled) {
    const builder = Builder()
      .from(toSdkEvmFrom(from))
      .to(to)
      .currency(currency)
      .recipient(recipient)
      .sender(signer)
      .swap({
        currencyTo: { location: currencyTo!.location },
        ...(exchange ? { exchange: [exchange] } : {}),
      });

    try {
      await builder.signAndSubmitAll();
    } finally {
      await builder.disconnect();
    }
    return;
  }

<% } %>  await Builder()
    .from(toSdkEvmFrom(from))
    .to(to)
    .currency(currency)
    .recipient(recipient)
    .sender(signer)
    .signAndSubmit();
};
