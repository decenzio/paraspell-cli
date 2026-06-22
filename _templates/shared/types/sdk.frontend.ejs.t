import type { TAssetInfo, TChain<% if (swap) { %>, TExchangeChain<% } %> } from "<%= sdkPackage %>";
<% if (client === 'papi') { %>
import type { PolkadotSigner } from "polkadot-api";
<% } %><% if (client === 'pjs' || client === 'dedot') { %>
import type { Signer } from "@polkadot/api/types";
import type { web3Accounts } from "@polkadot/extension-dapp";

export type ExtensionInjectedAccount = Awaited<ReturnType<typeof web3Accounts>>[number];
<% } %><% if (evmWallet) { %><% if (framework === 'vue') { %>
import type { ComputedRef, Ref } from "vue";
<% } %>
import type { WalletClient } from "viem";
import type { EIP1193Provider } from "mipd";
<% } %>

<%- h.includeShared('shared/types/common.ejs.t') %>

export type FormValues = {
  from: TChain;
  to: TChain;
  currencyOptionId: string;
  recipient: string;
  amount: string;
  currency: TAssetInfo;<% if (swap) { %>
  swapEnabled?: boolean;
  currencyTo?: TAssetInfo;
  exchange?: TExchangeChain;<% } %>
};

<%- h.includeShared('shared/types/wallet.client.ejs.t') %>
<% if (evmWallet) { %>
<%- h.includeShared('shared/types/wallet.evm.ejs.t') %>
<% } %>
