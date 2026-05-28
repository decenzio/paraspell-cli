/* EVM_FEATURE — entire file */

import { Builder, type TEvmChainFrom } from "@paraspell/sdk";
import { createWalletClient, http, type WalletClient, type Chain } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { darwinia, moonbeam, moonriver } from "viem/chains";
import "@paraspell/evm";
/* SNOWBRIDGE_FEATURE */
import { mainnet, sepolia } from "viem/chains";
import "@paraspell/evm-snowbridge";
/* END_SNOWBRIDGE_FEATURE */
import type { TransferParams } from "./types.js";

const VIEM_CHAIN_BY_ORIGIN: Partial<Record<string, Chain>> = {
  Moonbeam: moonbeam,
  Moonriver: moonriver,
  Darwinia: darwinia,
  /* SNOWBRIDGE_FEATURE */
  Ethereum: mainnet,
  EthereumTestnet: sepolia,
  /* END_SNOWBRIDGE_FEATURE */
};

type EvmChain = keyof typeof VIEM_CHAIN_BY_ORIGIN;

export function isChainEvm(chain: string): chain is EvmChain {
  return chain in VIEM_CHAIN_BY_ORIGIN;
}

function toSdkEvmFrom(chain: EvmChain): TEvmChainFrom {
  if (
    chain === "Moonbeam" ||
    chain === "Moonriver" ||
    chain === "Darwinia" ||
    chain === "Ethereum"
  ) {
    return chain;
  }
  /* SNOWBRIDGE_FEATURE */
  if (chain === "EthereumTestnet") {
    return "Ethereum";
  }
  /* END_SNOWBRIDGE_FEATURE */
  throw new Error(`Unsupported EVM origin: ${chain}`);
}

function getViemChainForOrigin(origin: EvmChain): Chain {
  const chain = VIEM_CHAIN_BY_ORIGIN[origin];
  if (!chain) {
    throw new Error(`No viem chain configured for origin: ${origin}`);
  }
  return chain;
}

function getEvmWalletClient(origin: EvmChain): WalletClient {
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

export async function submitEvmTransfer(
  params: TransferParams,
): Promise<string> {
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
