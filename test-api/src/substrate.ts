import { Keyring } from "@polkadot/keyring";
import { cryptoWaitReady } from "@polkadot/util-crypto";
import { Binary } from "polkadot-api";
import { getPolkadotSigner } from "polkadot-api/signer";

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

function createKeyringPair(secret: string) {
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
    (input) => pair.sign(input) as Uint8Array,
  );
}

export function ensureSubstrateTransferConfirmed(): boolean {
  if (process.env.CONFIRM_TRANSFER !== "true") {
    console.log(
      "\nDry run: Substrate transfer not broadcast. Re-run with CONFIRM_TRANSFER=true to " +
        "sign and submit for real.",
    );
    return false;
  }

  return true;
}

export { Binary };
