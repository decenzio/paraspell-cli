---
to: src/evm.ts
skip_if: <%= (!evmWallet).toString() %>
---
import {
  createWalletClient,
  http,
  isHex,
  type WalletClient,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { getEvmOriginChains } from "./evmOrigins.js";
import { getViemChainForOrigin } from "./getViemChain.js";

export function isEvmOrigin(chain: string): boolean {
  return getEvmOriginChains().includes(chain);
}

export function getEvmWalletClient(origin: string): WalletClient {
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

export function getEvmSenderAddress(origin: string): string {
  const walletClient = getEvmWalletClient(origin);
  const account = walletClient.account;
  if (!account) {
    throw new Error("EVM wallet client has no account configured.");
  }
  return account.address;
}
