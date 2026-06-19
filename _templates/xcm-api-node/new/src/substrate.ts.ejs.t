---
to: src/substrate.ts
---
import { Binary } from "polkadot-api";
import { getPolkadotSigner } from "polkadot-api/signer";
<%- h.includeShared('shared/node/substrate-keyring.ejs.t') %>

export async function getSubstrateSenderAddress(secret: string): Promise<string> {
  await ensureCryptoReady();
  return createKeyringPair(secret).address;
}

export async function getSignerFromSecret(secret: string) {
  await ensureCryptoReady();
  const pair = createKeyringPair(secret);
  return getPolkadotSigner(
    pair.publicKey,
    "Sr25519",
    (input) => signBytes(pair, input),
  );
}

export { Binary };
