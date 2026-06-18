import {
  Builder,
  createChainClient,
  UnsupportedOperationError,
  type Extrinsic,<% if (evmWallet) { %>
  isChainEvm,<% } %>
} from "@paraspell/sdk-pjs";
import type { Signer } from "@polkadot/api/types";
import type { FormValues<% if (evmWallet) { %>, SubmitOptions<% } %> } from "../types";
import { requireCurrency<% if (swap) { %>, requireSwapCurrencyTo<% } %> } from "../requireAsset";<% if (evm) { %>
import "@paraspell/evm";
<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %>
import { assertSubstrateOrigin } from "../evm/isEvmOrigin";<% if (evmWallet) { %>
import { submitEvmTransferFromForm } from "./evmTransfer";
<% } -%>

export async function buildTransaction(
  formValues: FormValues,
  senderAddress: string,
): Promise<Extrinsic[]> {
  const { from, to, recipient, amount<% if (swap) { %>, swapEnabled, currencyTo, exchange<% } %> } =
    formValues;

  assertSubstrateOrigin(from);
  const currency = requireCurrency(formValues.currency);
<% if (swap) { %>  if (swapEnabled) {
    const resolvedCurrencyTo = requireSwapCurrencyTo(swapEnabled, currencyTo);
    if (!resolvedCurrencyTo) {
      throw new UnsupportedOperationError("Swap destination currency is required.");
    }
    const contexts = await Builder()
      .from(from)
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

<% } %>  const api = await createChainClient(from);
  const tx = await Builder(api)
    .from(from)
    .to(to)
    .currency({ location: currency.location, amount })
    .recipient(recipient)
    .sender(senderAddress)
    .build();

  return [tx];
}

async function submitTransaction(
  tx: Extrinsic,
  senderAddress: string,
  signer: Signer,
): Promise<void> {
  await tx.signAsync(senderAddress, { signer });

  await new Promise<void>((resolve, reject) => {
    void tx
      .send((result) => {
        if (!result.status.isFinalized) {
          return;
        }

        const { dispatchError } = result;

        if (dispatchError) {
          if (dispatchError.isModule) {
            const { docs, name, section } = tx.registry.findMetaError(
              dispatchError.asModule,
            );
            reject(
              new UnsupportedOperationError(
                `${section}.${name}: ${docs.join(" ")}`,
              ),
            );
          } else {
            reject(new UnsupportedOperationError(dispatchError.toString()));
          }
          return;
        }

        resolve();
      })
      .catch((error) => {
        reject(error);
      });
  });
}

export const submitUsingSdk = async (
  formValues: FormValues,
  <% if (evmWallet) { %>options: SubmitOptions,<% } else { %>signer: Signer,
  senderAddress: string,<% } %>
): Promise<void> => {
<% if (evmWallet) { %>  if (isChainEvm(formValues.from)) {
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

  const txs = await buildTransaction(formValues, senderAddress);
  for (const tx of txs) {
    await submitTransaction(tx, senderAddress, signer);
  }
};
