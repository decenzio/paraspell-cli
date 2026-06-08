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

async function getSignerFromUri(uri: string) {
  if (!cryptoReady) {
    cryptoReady = cryptoWaitReady();
  }
  await cryptoReady;

  const keyring = new Keyring({ type: "sr25519" });
  const pair = keyring.addFromUri(uri);

  return getPolkadotSigner(
    pair.publicKey,
    "Sr25519",
    (input) => pair.sign(input) as Uint8Array,
  );
}

const submitApiTransaction = async (
  apiTx: ApiTransaction,
  sender: string,
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
    const signer = await getSignerFromUri(sender);
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
  sender: string,
): Promise<string[]> => {
  const hashes: string[] = [];
  for (const apiTx of transactions) {
    hashes.push(await submitApiTransaction(apiTx, sender));
  }
  return hashes;
};
