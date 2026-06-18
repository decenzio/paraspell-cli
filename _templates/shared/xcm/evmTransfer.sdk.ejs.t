import { Builder, isChainEvm } from "<%= sdkPackage %>";
import type { WalletClient } from "viem";
import type { EIP1193Provider } from "mipd";
import type { FormValues } from "../types";
import { requireCurrency<% if (swap) { %>, requireSwapCurrencyTo<% } %> } from "../requireAsset";
import { ensureEvmWalletClient } from "../evm";
<% if (evm) { %>import "@paraspell/evm";
<% } %><% if (snowbridge) { %>import "@paraspell/evm-snowbridge";
<% } %><% if (swap) { %>import "@paraspell/swap";
<% } -%>

export const submitEvmTransferFromForm = async (
  formValues: FormValues,
  walletClient: WalletClient,
  provider: EIP1193Provider,
): Promise<void> => {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;

  if (!isChainEvm(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }

  const currency = requireCurrency(formValues.currency);
  const signer = await ensureEvmWalletClient(walletClient, from, provider);

<% if (swap) { %>  if (swapEnabled) {
    const resolvedCurrencyTo = requireSwapCurrencyTo(swapEnabled, currencyTo);
    if (!resolvedCurrencyTo) {
      throw new Error("Swap destination currency is required.");
    }
    const builder = Builder()
      .from(from)
      .to(to)
      .currency({ location: currency.location, amount })
      .recipient(recipient)
      .sender(signer)
      .swap({
        currencyTo: { location: resolvedCurrencyTo.location },
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
    .from(from)
    .to(to)
    .currency({ location: currency.location, amount })
    .recipient(recipient)
    .sender(signer)
    .signAndSubmit();
};
