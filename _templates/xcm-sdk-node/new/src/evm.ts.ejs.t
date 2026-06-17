---
to: src/evm.ts
skip_if: <%= (!evmWallet).toString() %>
---
<% if (evm) { %>import {
  Builder,
  isChainEvm,
  type TChain,
} from "@paraspell/sdk";
import "@paraspell/evm";
<% } else { %>import { Builder, type TChain } from "@paraspell/sdk";
<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %>
import {
  createWalletClient,
  http,
  isHex,
  type WalletClient,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import type { TransferParams } from "./types.js";
import { getViemChainForOrigin } from "./getViemChain.js";

export function isEvmOrigin(chain: TChain): boolean {
<% if (evm) { %>  if (isChainEvm(chain)) {
    return true;
  }
<% } %><% if (snowbridge) { %>  if (chain === "Ethereum") {
    return true;
  }
<% } %>  return false;
}

export function getEvmWalletClient(origin: TChain): WalletClient {
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error(
      "PRIVATE_KEY env var is required for EVM transfers (0x-prefixed hex).",
    );
  }

  if (!isHex(privateKey)) {
    throw new Error("PRIVATE_KEY must be a 0x-prefixed hex string.");
  }

  const account = privateKeyToAccount(privateKey);
  return createWalletClient({
    account,
    chain: getViemChainForOrigin(origin),
    transport: http(),
  });
}

export async function submitEvmTransfer(params: TransferParams): Promise<string> {
  const { from, to, recipient, amount, currencyLocation } = params;

  if (!isEvmOrigin(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }
  if (!currencyLocation) {
    throw new Error("Currency location is required for EVM transfers.");
  }

  const walletClient = getEvmWalletClient(from);

  return await Builder()
    .from(from)
    .to(to)
    .currency({
      location: currencyLocation,
      amount,
    })
    .recipient(recipient)
    .sender(walletClient)
    .signAndSubmit();
}
