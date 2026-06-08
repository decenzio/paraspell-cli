---
to: src/submitSubstrate.ts
---
import axios from "axios";
import { Keyring } from "@polkadot/keyring";
import { cryptoWaitReady } from "@polkadot/util-crypto";
import { Binary } from "polkadot-api";
import { getPolkadotSigner } from "polkadot-api/signer";
import { createWsClient } from "polkadot-api/ws";
import { API_URL } from "./consts.js";
import type { ApiTransaction } from "./types.js";

let cryptoReady: Promise<boolean> | null = null;

async function getSignerFromMnemonic(mnemonic: string) {
  if (!cryptoReady) {
    cryptoReady = cryptoWaitReady();
  }
  await cryptoReady;

  const keyring = new Keyring({ type: "sr25519" });
  const pair = keyring.addFromMnemonic(mnemonic);

  return getPolkadotSigner(
    pair.publicKey,
    "Sr25519",
    (input) => pair.sign(input) as Uint8Array,
  );
}

const submitApiTransaction = async (
  apiTx: ApiTransaction,
  mnemonic: string,
): Promise<string> => {
  const response = await axios.get(
    `${API_URL}/chains/${apiTx.chain}/ws-endpoints`,
  );
  const endpoints = response.data as string[];
  if (endpoints.length === 0) {
    throw new Error(`No WS endpoints found for chain ${apiTx.chain}`);
  }

  const client = createWsClient(endpoints[0]);
  try {
    const signer = await getSignerFromMnemonic(mnemonic);
    const callData = Binary.fromHex(apiTx.tx);
    const tx = await client.getUnsafeApi().txFromCallData(callData);

    return await new Promise<string>((resolve, reject) => {
      tx.signSubmitAndWatch(signer).subscribe({
        next: (event) => {
          if (event.type === "finalized") {
            if (!event.ok) {
              reject(new Error("Transaction failed"));
            } else {
              resolve(event.txHash);
            }
          }
        },
        error: reject,
      });
    });
  } finally {
    client.destroy();
  }
};

export const submitSubstrateTransfers = async (
  transactions: ApiTransaction[],
): Promise<string[]> => {
  const mnemonic = process.env.SUBSTRATE_MNEMONIC;
  if (!mnemonic) {
    throw new Error(
      "SUBSTRATE_MNEMONIC env var is required for substrate API transfers.",
    );
  }

  const hashes: string[] = [];
  for (const apiTx of transactions) {
    hashes.push(await submitApiTransaction(apiTx, mnemonic));
  }
  return hashes;
};
