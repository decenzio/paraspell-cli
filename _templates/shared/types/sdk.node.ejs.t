import type { TChain, TLocation, TSubstrateChain } from "@paraspell/sdk";
<% if (client === 'pjs') { %>import type { Signer } from "@polkadot/api/types";

export type SignerPayloadRaw = Parameters<NonNullable<Signer["signRaw"]>>[0];
export type SignerPayloadJSON = Parameters<NonNullable<Signer["signPayload"]>>[0];
export type SignerResult = Awaited<ReturnType<NonNullable<Signer["signRaw"]>>>;

<% } %>

export type TransferParams = {
  from: TChain;
  to: TChain;
  amount: string;
  currencyLocation?: TLocation;
  recipient: string;
  currencyToLocation?: TLocation;
};
