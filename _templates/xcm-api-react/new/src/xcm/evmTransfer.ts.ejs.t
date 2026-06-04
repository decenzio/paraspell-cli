---
to: src/xcm/evmTransfer.ts
skip_if: <%= (!evm).toString() %>
---
import { Builder, type TChain } from "@paraspell/sdk";
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
  if (!isChainEvm(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }
  const signer = await ensureEvmWalletClient(walletClient, from);
  await Builder()
    .from(toSdkEvmFrom(from))
    .to(to as TChain)
    .currency({
      location: formValues.currency.location,
      amount,
    })
    .recipient(recipient)
    .sender(signer)
    .signAndSubmit();
};
