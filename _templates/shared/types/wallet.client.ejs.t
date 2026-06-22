<% if (client === 'papi' || projectKind === 'api') { %>
export type PapiWalletConnection = {
  address: string;
  signer: PolkadotSigner;
};

export type PapiWalletControlsProps = WalletControlsSubstrateProps;
<% } %><% if (client === 'pjs' || client === 'dedot') { %>

export type ExtensionWalletConnection = {
  address: string;
  signer: Signer;
};

export type ExtensionWalletControlsProps = WalletControlsSubstrateProps;
<% } %>
