---
to: src/substrate.ts
---
import { Keyring } from "@polkadot/keyring";
import { cryptoWaitReady } from "@polkadot/util-crypto";
import type { KeyringPair } from "@polkadot/keyring/types";<% if (client === 'papi') { %>
import { getPolkadotSigner } from "polkadot-api/signer";
import type { PolkadotSigner } from "polkadot-api";<% } else if (client === 'pjs') { %>
import type { Signer } from "@polkadot/api/types";
import type { TPjsSigner } from "@paraspell/sdk-pjs";<% } %>

let cryptoReady: Promise<boolean> | null = null;

async function ensureCryptoReady(): Promise<void> {
  if (!cryptoReady) {
    cryptoReady = cryptoWaitReady();
  }
  await cryptoReady;
}

export function getSubstrateMnemonic(): string {
  const secret = process.env.SUBSTRATE_MNEMONIC;
  if (!secret) {
    throw new Error(
      "SUBSTRATE_MNEMONIC env var is required for Substrate transfers (mnemonic or //Dev URI).",
    );
  }

  return secret;
}

function createKeyringPair(secret: string): KeyringPair {
  const keyring = new Keyring({ type: "sr25519" });
  try {
    if (secret.startsWith("//")) {
      return keyring.addFromUri(secret);
    }
    if (secret.includes(" ")) {
      return keyring.addFromMnemonic(secret);
    }
    return keyring.addFromUri(secret);
  } catch {
    throw new Error(
      "SUBSTRATE_MNEMONIC must be a BIP39 mnemonic (quote it in .env) or a //Dev URI like //Alice.",
    );
  }
}
<% if (client === 'pjs') { %>
type SignerPayloadRaw = Parameters<NonNullable<Signer["signRaw"]>>[0];
type SignerPayloadJSON = Parameters<NonNullable<Signer["signPayload"]>>[0];
type SignerResult = Awaited<ReturnType<NonNullable<Signer["signRaw"]>>>;

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

type KeyringPairWithPayload = KeyringPair & {
  signPayload(payload: SignerPayloadJSON): Uint8Array;
};

function keyringPairToPjsSigner(pair: KeyringPair): TPjsSigner {
  const signingPair = pair as KeyringPairWithPayload;
  const signer: Signer = {
    signRaw: async (raw: SignerPayloadRaw): Promise<SignerResult> => ({
      id: 1,
      signature: u8aToHex(pair.sign(hexToU8a(raw.data))),
    }),
    signPayload: async (payload: SignerPayloadJSON): Promise<SignerResult> => ({
      id: 1,
      signature: u8aToHex(signingPair.signPayload(payload)),
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
    (input) => pair.sign(input) as Uint8Array,
  );
<% } else if (client === 'pjs') { %>
  return keyringPairToPjsSigner(pair);
<% } else { %>
  return pair;
<% } %>
}
