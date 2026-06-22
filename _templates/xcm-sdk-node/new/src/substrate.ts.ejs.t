---
to: src/substrate.ts
---
<% if (client === 'papi') { -%>
import { getPolkadotSigner } from "polkadot-api/signer";
import type { PolkadotSigner } from "polkadot-api";
<% } else if (client === 'pjs') { -%>
import type { Signer } from "@polkadot/api/types";
import { TypeRegistry } from "@polkadot/types/create";
import type { TPjsSigner } from "@paraspell/sdk-pjs";
<% } -%>
<%- h.includeShared('shared/node/substrate-keyring.ejs.t') %>
<% if (client === 'pjs') { %>
const hexToU8a = (value: string): Uint8Array => {
  const hex = value.startsWith("0x") ? value.slice(2) : value;
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < bytes.length; i++) {
    bytes[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
};

const u8aToHex = (bytes: Uint8Array): `0x${string}` =>
  `0x${Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("")}`;

const typeRegistry = new TypeRegistry();

const keyringPairToPjsSigner = (pair: KeyringPair): TPjsSigner => {
  const signer = {
    signRaw: async (raw) => ({
      id: 1,
      signature: u8aToHex(signBytes(pair, hexToU8a(raw.data))),
    }),
    signPayload: async (payload) => {
      const { signature } = typeRegistry
        .createType("ExtrinsicPayload", payload, { version: payload.version })
        .sign(pair);

      return { id: 1, signature };
    },
  } satisfies Signer;

  return { address: pair.address, signer };
};
<% } %>

export const getSubstrateSigner = async (): Promise<<%= client === 'papi' ? 'PolkadotSigner' : client === 'pjs' ? 'TPjsSigner' : 'KeyringPair' %>> => {
  await ensureCryptoReady();
  const pair = createKeyringPair(getSubstrateMnemonic());
<% if (client === 'papi') { %>
  return getPolkadotSigner(
    pair.publicKey,
    "Sr25519",
    (input) => signBytes(pair, input),
  );
<% } else if (client === 'pjs') { %>
  return keyringPairToPjsSigner(pair);
<% } else { %>
  return pair;
<% } %>
};
