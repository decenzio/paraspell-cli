<% if (swap || evmWallet) { %>import { UnsupportedOperationError } from "@paraspell/sdk";
<% } %>import { type TSubstrateChain } from "@paraspell/sdk";
import {
  Builder,
  createChainClient,
  type TDedotExtrinsic,
} from "@paraspell/sdk-dedot";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../types";
import { requireCurrency<% if (swap) { %>, requireSwapCurrencyTo<% } %> } from "../requireAsset";<% if (evm) { %>
import "@paraspell/evm";
<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %><% if (evmWallet) { %>
import { assertSubstrateOrigin, isEvmOrigin } from "../evm";
import type { WalletClient } from "viem";
import type { EIP1193Provider } from "mipd";
import { submitEvmTransferFromForm } from "./evmTransfer";

export type SubmitOptions =
  | { kind: "substrate"; signer: Signer; senderAddress: string }
  | { kind: "evm"; walletClient: WalletClient; provider: EIP1193Provider };
<% } -%>

export async function buildTransactions(
  formValues: FormValues,
  senderAddress: string,
): Promise<TDedotExtrinsic[]> {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;

<% if (evmWallet) { %>  assertSubstrateOrigin(from);

<% } %>  const substrateFrom = from as TSubstrateChain;
  const currency = requireCurrency(formValues.currency);

<% if (swap) { %>  if (swapEnabled) {
    const resolvedCurrencyTo = requireSwapCurrencyTo(swapEnabled, currencyTo);
    if (!resolvedCurrencyTo) {
      throw new UnsupportedOperationError("Swap destination currency is required.");
    }
    const contexts = await Builder()
      .from(substrateFrom)
      .to(to)
      .currency({ location: currency.location, amount })
      .recipient(recipient)
      .swap({
        currencyTo: { location: resolvedCurrencyTo.location },
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
    .currency({ location: currency.location, amount })
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
  <% if (evmWallet) { %>options: SubmitOptions,<% } else { %>signer: Signer,
  senderAddress: string,<% } %>
): Promise<void> => {
<% if (evmWallet) { %>  if (isEvmOrigin(formValues.from)) {
    if (options.kind !== "evm") {
      throw new UnsupportedOperationError(
        "EVM origin requires a connected EVM wallet.",
      );
    }

    await submitEvmTransferFromForm(
      formValues,
      options.walletClient,
      options.provider,
    );
    return;
  }

  if (options.kind !== "substrate") {
    throw new UnsupportedOperationError(
      "Substrate origin requires a Polkadot extension wallet.",
    );
  }

  const { signer, senderAddress } = options;

<% } %>  if (!senderAddress) {
    alert("No account selected, connect wallet first");
    return;
  }

  const txs = await buildTransactions(formValues, senderAddress);

  for (const tx of txs) {
    await submitTransaction(tx, senderAddress, signer);
  }
};
