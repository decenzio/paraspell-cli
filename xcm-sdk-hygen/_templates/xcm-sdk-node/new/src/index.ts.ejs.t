---
to: src/index.ts
---
<% if (client === 'papi') { %>import { Builder } from "@paraspell/sdk";<% } else if (client === 'pjs') { %>import {
  Builder,
  createChainClient,
} from "@paraspell/sdk-pjs";<% } else { %>import {
  Builder,
  createChainClient,
} from "@paraspell/sdk-dedot";<% } %><% if (evm) { %>
import { isChainEvm, submitEvmTransfer } from "./evm.js";<% } %>
import type { SubstrateTransferParams, TransferParams } from "./types.js";

const defaults: TransferParams = {
  from: "<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'AssetHubPolkadot' %>",
  to: "Hydration",
  amount: "0.1",
  currencySymbol: "DOT",
  sender: "//Alice",
  recipient: "//Bob",<% if (swap) { %>
  currencyToSymbol: "USDC",<% } %>
};

async function transferAsset(
  params: Partial<TransferParams> = {},
): Promise<string | string[]> {
  const opts: TransferParams = { ...defaults, ...params };

<% if (evm) { %>  if (isChainEvm(opts.from)) {
    return await submitEvmTransfer(opts);
  }

<% } %>  const substrateOpts = opts as SubstrateTransferParams;
<% if (client === 'papi') { %>
  const builder = Builder()
    .from(substrateOpts.from)
    .to(substrateOpts.to)
    .currency({
      symbol: substrateOpts.currencySymbol,
      amount: substrateOpts.amount,
    })
    .recipient(substrateOpts.recipient)
    .sender(substrateOpts.sender);
<% } else { %>
  const client = await createChainClient(substrateOpts.from);
  const builder = Builder(client)
    .from(substrateOpts.from)
    .to(substrateOpts.to)
    .currency({
      symbol: substrateOpts.currencySymbol,
      amount: substrateOpts.amount,
    })
    .recipient(substrateOpts.recipient)
    .sender(substrateOpts.sender);
<% } %>
<% if (swap) { %>
  if (substrateOpts.currencyToSymbol) {
    builder.swap({
      currencyTo: { symbol: substrateOpts.currencyToSymbol },
      ...(substrateOpts.exchange
        ? { exchange: [substrateOpts.exchange] }
        : {}),
    });
  }
<% } %>

  try {
<% if (swap) { %>
    if (substrateOpts.currencyToSymbol) {
      return await builder.signAndSubmitAll();
    }
<% } %>
    return await builder.signAndSubmit();
  } finally {
    await builder.disconnect();
  }
}

const result = await transferAsset();

if (Array.isArray(result)) {
  console.log("Submitted XCM transfer(s):", result.join(", "));
} else {
  console.log("Submitted XCM transfer:", result);
}
