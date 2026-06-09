---
to: src/transfer.ts
---
<% if (swap) { %>import "@paraspell/swap";
<% } %><% if (client === 'papi') { %>import { Builder } from "@paraspell/sdk";<% } else if (client === 'pjs') { %>import {
  Builder,
  createChainClient,
} from "@paraspell/sdk-pjs";<% } else { %>import {
  Builder,
  createChainClient,
} from "@paraspell/sdk-dedot";<% } %><% if (evm && !snowbridge) { %>
import { Native } from "@paraspell/sdk";<% } %><% if (evm) { %>
import { isChainEvm, submitEvmTransfer } from "./evm.js";<% } %>
import { getSubstrateSigner } from "./substrate.js";
import type { TransferParams } from "./types.js";<% if (evm) { %>
import type { TSubstrateChain } from "@paraspell/sdk";<% } %>

const defaults: TransferParams = {
  from: "<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'Astar' %>",
  to: "Hydration",
  amount: "0.1",
<% if (snowbridge) { -%>
  currencySymbol: "ETH",
<% } else if (evm) { -%>
  currencySymbol: Native("GLMR"),
<% } else { -%>
  currencySymbol: "ASTR",
<% } -%>
  recipient: "//Bob",<% if (swap) { %>
  currencyToSymbol: "<%= evm ? 'USDC' : 'DOT' %>",<% } %>
};

export async function transferAsset(): Promise<string | string[]> {
  const opts = defaults;

<% if (evm) { %>  if (isChainEvm(opts.from)) {
    return await submitEvmTransfer(opts);
  }

<% } %><% if (evm && client !== 'papi') { %>
  const substrateFrom = opts.from as TSubstrateChain;
<% } %>
  const sender = await getSubstrateSigner();
<% if (swap) { %>  if (opts.currencyToSymbol) {
    const swapBuilder = Builder()
      .from(opts.from)
      .to(opts.to)
      .currency({
        symbol: opts.currencySymbol,
        amount: opts.amount,
      })
      .recipient(opts.recipient)
      .sender(sender)
      .swap({
        currencyTo: { symbol: opts.currencyToSymbol },
        ...(opts.exchange ? { exchange: [opts.exchange] } : {}),
      });

    try {
      return await swapBuilder.signAndSubmitAll();
    } finally {
      await swapBuilder.disconnect();
    }
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
    .sender(sender);
<% } else { %>
  const client = await createChainClient(<% if (evm) { %>substrateFrom<% } else { %>opts.from<% } %>);
  const builder = Builder(client)
    .from(<% if (evm) { %>substrateFrom<% } else { %>opts.from<% } %>)
    .to(opts.to)
    .currency({
      symbol: opts.currencySymbol,
      amount: opts.amount,
    })
    .recipient(opts.recipient)
    .sender(sender);
<% } %>

  try {
    return await builder.signAndSubmit();
  } finally {
    await builder.disconnect();
  }
}
