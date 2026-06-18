<% if (client === 'papi' || projectKind === 'api') { %>
import type { PolkadotSigner } from "polkadot-api";

export type PapiWalletConnection = {
  address: string;
  signer: PolkadotSigner;
};

export type PapiWalletControlsProps = WalletControlsSubstrateProps;
<% } %><% if (client === 'pjs') { %>
import type { Signer } from "@polkadot/api/types";
import type { InjectedAccountWithMeta } from "@polkadot/extension-inject/types";

export type PjsInjectedAccount = InjectedAccountWithMeta;

export type PjsWalletConnection = {
  address: string;
  signer: Signer;
};

export type PjsWalletControlsProps = WalletControlsSubstrateProps;
<% } %><% if (client === 'dedot') { %>
import type { Signer } from "@polkadot/api/types";

export type ExtensionInjectedSigner = Signer;

export type WindowWithInjectedWeb3 = Window & {
  injectedWeb3?: Record<
    string,
    {
      enable: (dappName?: string) => Promise<{
        signer: ExtensionInjectedSigner;
        accounts: { get: () => Promise<WalletAccountOption[]> };
      }>;
    }
  >;
};

export type DedotWalletConnection = {
  address: string;
  signer: ExtensionInjectedSigner;
};

export type DedotWalletControlsProps = WalletControlsSubstrateProps;
<% } %>
