import { Keyring } from "@polkadot/keyring";
import { cryptoWaitReady } from "@polkadot/util-crypto";
import type { KeyringPair } from "@polkadot/keyring/types";

let cryptoReady: Promise<boolean> | null = null;

export async function ensureCryptoReady(): Promise<void> {
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

export function createKeyringPair(secret: string): KeyringPair {
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

export function signBytes(pair: KeyringPair, input: Uint8Array): Uint8Array {
  return Uint8Array.from(pair.sign(input));
}
