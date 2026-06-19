---
to: src/substrate.ts
---
<% if (client === 'papi') { -%>
import { getPolkadotSigner } from "polkadot-api/signer";
import type { PolkadotSigner } from "polkadot-api";
<% } else if (client === 'pjs') { -%>
import type { Signer } from "@polkadot/api/types";
import type { TPjsSigner } from "@paraspell/sdk-pjs";
import type {
  SignerPayloadJSON,
  SignerPayloadRaw,
  SignerResult,
} from "./types.js";
<% } -%>
<%- h.includeShared('shared/node/substrate-keyring.ejs.t') %>
<% if (client === 'pjs') { %>
function hexToU8a(value: string): Uint8Array {
  const hex = value.startsWith("0x") ? value.slice(2) : value;
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < bytes.length; i++) {
    bytes[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

function u8aToHex(bytes: Uint8Array): `0x${string}` {
  return `0x${Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("")}`;
}

function hasSignPayload(
  pair: KeyringPair,
): pair is KeyringPair & {
  signPayload: (payload: SignerPayloadJSON) => Uint8Array;
} {
  return "signPayload" in pair && typeof pair.signPayload === "function";
}

function keyringPairToPjsSigner(pair: KeyringPair): TPjsSigner {
  if (!hasSignPayload(pair)) {
    throw new Error("Keyring pair does not support payload signing.");
  }
  const signer: Signer = {
    signRaw: async (raw: SignerPayloadRaw): Promise<SignerResult> => ({
      id: 1,
      signature: u8aToHex(signBytes(pair, hexToU8a(raw.data))),
    }),
    signPayload: async (payload: SignerPayloadJSON): Promise<SignerResult> => ({
      id: 1,
      signature: u8aToHex(pair.signPayload(payload)),
    }),
  };

  return { address: pair.address, signer };
}
<% } %>

export async function getSubstrateSigner(): Promise<<%= client === 'papi' ? 'PolkadotSigner' : client === 'pjs' ? 'TPjsSigner' : 'KeyringPair' %>> {
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
}
