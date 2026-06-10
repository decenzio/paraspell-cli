---
to: src/evm.ts
skip_if: <%= (!evm).toString() %>
---
import { Builder, type TChain, type TDestination } from "<%= sdkPackage %>";
import type { TEvmChainFrom } from "@paraspell/sdk";
import { createWalletClient, http, type WalletClient, type Chain } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import {
  darwinia,
  moonbeam,
  moonriver<% if (snowbridge) { %>,
  mainnet,
  sepolia<% } %>,
} from "viem/chains";
import "@paraspell/evm";<% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";<% } %>
import type { TransferParams } from "./types.js";

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

export function isChainEvm(chain: TChain): chain is EvmChain {
  return EVM_ORIGIN_CHAINS.some((origin) => origin === chain);
}

function toSdkEvmFrom(chain: EvmChain): TEvmChainFrom {
  if (
    chain === "Moonbeam" ||
    chain === "Moonriver" ||
    chain === "Darwinia"
  ) {
    return chain;
  }
<% if (snowbridge) { %>
  if (chain === "EthereumTestnet") {
    return "Ethereum" as TEvmChainFrom;
  }
  if (chain === "Ethereum") {
    return chain as TEvmChainFrom;
  }
<% } %>
  throw new Error(`Unsupported EVM origin: ${chain}`);
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

export async function submitEvmTransfer(params: TransferParams): Promise<string> {
  const { from, to, recipient, amount, currencySymbol } = params;

  if (!isChainEvm(from)) {
    throw new Error(`Unsupported EVM origin: ${from}`);
  }
  const walletClient = getEvmWalletClient(from);

  return await Builder()
    .from(toSdkEvmFrom(from))
    .to(to)
    .currency({
      symbol: currencySymbol,
      amount,
    })
    .recipient(recipient)
    .sender(walletClient)
    .signAndSubmit();
}
