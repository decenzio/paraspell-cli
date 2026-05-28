---
to: src/evm/evmWalletClient.ts
skip_if: <%= (!evm).toString() %>
---
import { SUBSTRATE_CHAINS, type TChain, type TEvmChainFrom } from "<%= sdkPackage %>";
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

export function isChainEvm(chain: TChain): chain is EvmChain {
  return chain in VIEM_CHAIN_BY_ORIGIN;
}

export function toSdkEvmFrom(chain: EvmChain): TEvmChainFrom {
  if (chain === "Moonbeam" || chain === "Moonriver" || chain === "Darwinia" || chain === "Ethereum") {
    return chain;
  }<% if (snowbridge) { %>
  if (chain === "EthereumTestnet") {
    return "Ethereum";
  }<% } %>
  throw new Error(`Unsupported EVM origin: ${chain}`);
}

export const VIEM_CHAIN_BY_ORIGIN: Partial<Record<TChain, Chain>> = {
  Moonbeam: moonbeam,
  Moonriver: moonriver,
  Darwinia: darwinia,<% if (snowbridge) { %>
  Ethereum: mainnet,
  EthereumTestnet: sepolia,<% } %>
};

export type EvmChain = keyof typeof VIEM_CHAIN_BY_ORIGIN;

export function getOriginChainsForWallet(isEvmWallet: boolean): TChain[] {
  if (isEvmWallet) {
    return Object.keys(VIEM_CHAIN_BY_ORIGIN) as EvmChain[];
  }
  return [...SUBSTRATE_CHAINS];
}

export function getViemChainForOrigin(origin: TChain): Chain {
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
      "No EVM wallet found. Install an EVM-supported wallet (EIP-1193 provider).",
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

export async function switchWalletToOrigin(origin: TChain): Promise<void> {
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

export function createEvmWalletClient(origin: TChain): WalletClient {
  return createWalletClient({
    chain: getViemChainForOrigin(origin),
    transport: custom(getEthereumProvider()),
  });
}

export async function ensureEvmWalletClient(
  walletClient: WalletClient,
  origin: TChain,
): Promise<WalletClient> {
  if (!walletClient.account) {
    throw new Error(
      "EVM wallet has no account. Disconnect and connect again.",
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
