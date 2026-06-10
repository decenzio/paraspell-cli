---
to: src/evm.ts
skip_if: <%= (!evm).toString() %>
---
import { createWalletClient, http, type WalletClient, type Chain } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import {
  darwinia,
  moonbeam,
  moonriver<% if (snowbridge) { %>,
  mainnet,
  sepolia<% } %>,
} from "viem/chains";

export const EVM_ORIGIN_CHAINS = [
  "Moonbeam",
  "Moonriver",
  "Darwinia",<% if (snowbridge) { %>
  "Ethereum",
  "EthereumTestnet",<% } %>
] as const;

export type EvmChain = (typeof EVM_ORIGIN_CHAINS)[number];

const VIEM_CHAIN_BY_ORIGIN: Record<EvmChain, Chain> = {
  Moonbeam: moonbeam,
  Moonriver: moonriver,
  Darwinia: darwinia,<% if (snowbridge) { %>
  Ethereum: mainnet,
  EthereumTestnet: sepolia,<% } %>
};

export function isChainEvm(chain: string): chain is EvmChain {
  return EVM_ORIGIN_CHAINS.some((origin) => origin === chain);
}

function getViemChainForOrigin(origin: EvmChain): Chain {
  return VIEM_CHAIN_BY_ORIGIN[origin];
}

export function getEvmWalletClient(origin: EvmChain): WalletClient {
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error(
      "PRIVATE_KEY env var is required for EVM transfers (0x-prefixed hex).",
    );
  }

  const account = privateKeyToAccount(privateKey as `0x${string}`);
  return createWalletClient({
    account,
    chain: getViemChainForOrigin(origin),
    transport: http(),
  });
}

export function getEvmSenderAddress(origin: EvmChain): string {
  return getEvmWalletClient(origin).account!.address;
}
