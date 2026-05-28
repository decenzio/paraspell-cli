---
to: src/index.ts
---
<% if (client === 'papi') { %>import { Builder } from "@paraspell/sdk";<% } else if (client === 'pjs') { %>import {
  Builder,
  createChainClient,
} from "@paraspell/sdk-pjs";<% } else { %>import {
  Builder,
  createChainClient,
} from "@paraspell/sdk-dedot";<% } %>
import { Native<% if (swap) { %>, Foreign<% } %> } from "@paraspell/sdk";<% if (evm) { %>
import { isChainEvm, submitEvmTransfer } from "./evm.js";<% } %>
import type { TransferParams } from "./types.js";

const defaults: TransferParams = {
  from: "<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'AssetHubPolkadot' %>",
  to: "Hydration",
  amount: "0.1",
  currencySymbol: <%= snowbridge ? 'Native("ETH")' : evm ? 'Native("GLMR")' : 'Native("DOT")' %>,
  sender: "//Alice",
  recipient: "//Bob",<% if (swap) { %>
  currencyToSymbol: Foreign("USDC"),<% } %>
};

async function transferAsset(
  params: Partial<TransferParams> = {},
): Promise<string | string[]> {
  const opts: TransferParams = { ...defaults, ...params };

<% if (evm) { %>  if (isChainEvm(opts.from)) {
    return await submitEvmTransfer(opts);
  }

<% } %><% if (client === 'papi') { %>
  const builder = Builder()
    .from(opts.from)
    .to(opts.to)
    .currency({
      symbol: opts.currencySymbol,
      amount: opts.amount,
    })
    .recipient(opts.recipient)
    .sender(opts.sender);
<% } else { %>
  const client = await createChainClient(opts.from);
  const builder = Builder(client)
    .from(opts.from)
    .to(opts.to)
    .currency({
      symbol: opts.currencySymbol,
      amount: opts.amount,
    })
    .recipient(opts.recipient)
    .sender(opts.sender);
<% } %>
<% if (swap) { %>
  if (opts.currencyToSymbol) {
    builder.swap({
      currencyTo: { symbol: opts.currencyToSymbol },
      ...(opts.exchange ? { exchange: [opts.exchange] } : {}),
    });
  }
<% } %>

  try {
<% if (swap) { %>
    if (opts.currencyToSymbol) {
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
