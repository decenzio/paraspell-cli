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

export function isChainEvm(chain: TChain): chain is EvmChain {
  return EVM_ORIGIN_CHAINS.some((origin) => origin === chain);
}

export function toSdkEvmFrom(chain: EvmChain): TEvmChainFrom {
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

export function getOriginChainsForWallet(isEvmWallet: boolean): TChain[] {
  if (isEvmWallet) {
    return [...EVM_ORIGIN_CHAINS];
  }
  return [...SUBSTRATE_CHAINS];
}

export function getViemChainForOrigin(origin: TChain): Chain {
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

const getAddEthereumChainParams = (chain: Chain) => ({
  chainId: numberToHex(chain.id),
  chainName: chain.name,
  nativeCurrency: chain.nativeCurrency,
  rpcUrls: chain.rpcUrls.default.http,
  blockExplorerUrls: chain.blockExplorers?.default?.url
    ? [chain.blockExplorers.default.url]
    : undefined,
});

type WalletRpcError = Error & {
  code?: number;
};

function readHexString(value: unknown): string {
  if (typeof value !== "string") {
    throw new Error("Wallet RPC returned a non-string chain id");
  }
  return value;
}

function isAddChainRequired(error: unknown): boolean {
  return (error as WalletRpcError).code === 4902;
}

export async function switchWalletToOrigin(origin: TChain): Promise<void> {
  const chain = getViemChainForOrigin(origin);
  const provider = getEthereumProvider();
  const chainId = numberToHex(chain.id);

  const currentChainId = readHexString(
    await provider.request({ method: "eth_chainId" }),
  );
  if (currentChainId.toLowerCase() === chainId.toLowerCase()) {
    return;
  }

  try {
    await provider.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId }],
    });
  } catch (error) {
    if (!isAddChainRequired(error)) {
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
  const address: Address = walletClient.account.address;

  await switchWalletToOrigin(origin);

  return createWalletClient({
    account: address,
    chain: getViemChainForOrigin(origin),
    transport: custom(getEthereumProvider()),
  });
}
