<% if (client === 'papi' || projectKind === 'api') { %>
export type PapiWalletConnection = {
  address: string;
  signer: PolkadotSigner;
};

export type PapiWalletControlsProps = WalletControlsSubstrateProps;
<% } %><% if (client === 'pjs') { %>
export type PjsInjectedAccount = InjectedAccountWithMeta;

export type PjsWalletConnection = {
  address: string;
  signer: Signer;
};

export type PjsWalletControlsProps = WalletControlsSubstrateProps;
<% } %><% if (client === 'dedot') { %>
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
