import {
  createWalletClient,
  custom,
  type Address,
  type Chain,
  type EIP1193Provider,
  type WalletClient,
} from "viem";
import { darwinia, moonbeam, moonriver } from "viem/chains";<% if (snowbridge) { %>
import { mainnet, sepolia } from "viem/chains";<% } %>

export const EVM_ORIGIN_CHAINS = [
  "Moonbeam",
  "Moonriver",
  "Darwinia",<% if (snowbridge) { %>
  "Ethereum",
  "EthereumTestnet",<% } %>
] as const;

export type EvmChain = (typeof EVM_ORIGIN_CHAINS)[number];

export const VIEM_CHAIN_BY_ORIGIN: Record<EvmChain, Chain> = {
  Moonbeam: moonbeam,
  Moonriver: moonriver,
  Darwinia: darwinia,<% if (snowbridge) { %>
  Ethereum: mainnet,
  EthereumTestnet: sepolia,<% } %>
};

export function isChainEvm(chain: string): chain is EvmChain {
  return EVM_ORIGIN_CHAINS.some((origin) => origin === chain);
}

export function getViemChainForOrigin(origin: string): Chain {
  if (!isChainEvm(origin)) {
    throw new Error(`No viem chain configured for origin: ${origin}`);
  }
  return VIEM_CHAIN_BY_ORIGIN[origin];
}

declare global {
  interface Window {
    ethereum?: EIP1193Provider;
  }
}

export function getEthereumProvider(): EIP1193Provider {
  if (!window.ethereum) {
    throw new Error(
      "No EVM-compatible wallet found. Install an EVM wallet (EIP-1193 provider) and try again.",
    );
  }
  return window.ethereum;
}

export function createEvmWalletClient(origin: string): WalletClient {
  return createWalletClient({
    chain: getViemChainForOrigin(origin),
    transport: custom(getEthereumProvider()),
  });
}

export async function ensureEvmWalletClient(
  walletClient: WalletClient,
  origin: string,
): Promise<WalletClient> {
  if (!walletClient.account) {
    throw new Error(
      "Wallet has no account. Disconnect and connect again.",
    );
  }
  const address: Address = walletClient.account.address;

  return createWalletClient({
    account: address,
    chain: getViemChainForOrigin(origin),
    transport: custom(getEthereumProvider()),
  });
}
