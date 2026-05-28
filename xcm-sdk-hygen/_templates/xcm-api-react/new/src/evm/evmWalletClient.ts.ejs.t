---
to: src/evm/evmWalletClient.ts
skip_if: <%= (!evm).toString() %>
---
import { SUBSTRATE_CHAINS } from "@paraspell/sdk";
import type { TEvmChainFrom } from "@paraspell/sdk";
import {
  createWalletClient,
  custom,
  numberToHex,
  type Address,
  type Chain,
  type EIP1193Provider,
  type WalletClient,
} from "viem";
import { darwinia, moonbeam, moonriver } from "viem/chains";<% if (snowbridge) { %>
import { mainnet, sepolia } from "viem/chains";<% } %>

export function isChainEvm(chain: string): chain is EvmChain {
  return chain in VIEM_CHAIN_BY_ORIGIN;
}

export function toSdkEvmFrom(chain: EvmChain): TEvmChainFrom {
  if (
    chain === "Moonbeam" ||
    chain === "Moonriver" ||
    chain === "Darwinia" ||
    chain === "Ethereum"
  ) {
    return chain as TEvmChainFrom;
  }<% if (snowbridge) { %>
  if (chain === "EthereumTestnet") {
    return "Ethereum" as TEvmChainFrom;
  }<% } %>
  throw new Error(`Unsupported EVM origin: ${chain}`);
}

export const VIEM_CHAIN_BY_ORIGIN: Partial<Record<string, Chain>> = {
  Moonbeam: moonbeam,
  Moonriver: moonriver,
  Darwinia: darwinia,<% if (snowbridge) { %>
  Ethereum: mainnet,
  EthereumTestnet: sepolia,<% } %>
};

export type EvmChain = keyof typeof VIEM_CHAIN_BY_ORIGIN;

export function getOriginChainsForWallet(isEvmWallet: boolean): string[] {
  if (isEvmWallet) {
    return Object.keys(VIEM_CHAIN_BY_ORIGIN);
  }
  return [...SUBSTRATE_CHAINS];
}

export function filterChainsForWallet(
  chains: string[],
  isEvmWallet: boolean,
): string[] {
  if (chains.length === 0) {
    return getOriginChainsForWallet(isEvmWallet);
  }
  return chains.filter((chain) =>
    isEvmWallet ? isChainEvm(chain) : !isChainEvm(chain),
  );
}

export function getViemChainForOrigin(origin: string): Chain {
  const chain = VIEM_CHAIN_BY_ORIGIN[origin as EvmChain];
  if (!chain) {
    throw new Error(`No viem chain configured for origin: ${origin}`);
  }
  return chain;
}

declare global {
  interface Window {
    ethereum?: EIP1193Provider;
  }
}

export function getEthereumProvider(): EIP1193Provider {
  if (!window.ethereum) {
    throw new Error(
      "No EVM wallet found. Install MetaMask or another EIP-1193 provider.",
    );
  }
  return window.ethereum;
}

const getAddEthereumChainParams = (chain: Chain) => ({
  chainId: numberToHex(chain.id),
  chainName: chain.name,
  nativeCurrency: chain.nativeCurrency,
  rpcUrls: chain.rpcUrls.default.http,
  blockExplorerUrls: chain.blockExplorers?.default?.url
    ? [chain.blockExplorers.default.url]
    : undefined,
});

export async function switchWalletToOrigin(origin: string): Promise<void> {
  const chain = getViemChainForOrigin(origin);
  const provider = getEthereumProvider();
  const chainId = numberToHex(chain.id);

  const currentChainId = (await provider.request({
    method: "eth_chainId",
  })) as string;
  if (currentChainId.toLowerCase() === chainId.toLowerCase()) {
    return;
  }

  try {
    await provider.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId }],
    });
  } catch (error) {
    if ((error as { code?: number }).code !== 4902) {
      throw error;
    }
    await provider.request({
      method: "wallet_addEthereumChain",
      params: [getAddEthereumChainParams(chain)],
    });
    await provider.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId }],
    });
  }
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
      "MetaMask wallet has no account. Disconnect and connect again.",
    );
  }
  const address = walletClient.account.address;

  await switchWalletToOrigin(origin);

  return createWalletClient({
    account: address as Address,
    chain: getViemChainForOrigin(origin),
    transport: custom(getEthereumProvider()),
  });
}
