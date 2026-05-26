/* EVM_FEATURE — entire file */

import { SUBSTRATE_CHAINS, type TChain } from "@paraspell/sdk";
import type { TEvmChainFrom } from "@paraspell/sdk-pjs";
import {
  createWalletClient,
  custom,
  numberToHex,
  type Address,
  type Chain,
  type EIP1193Provider,
  type WalletClient,
} from "viem";
import { darwinia, moonbeam, moonriver } from "viem/chains";
/* SNOWBRIDGE_FEATURE */
import { mainnet, sepolia } from "viem/chains";
/* END_SNOWBRIDGE_FEATURE */

export function isChainEvm(chain: TChain): chain is EvmChain {
  return chain in VIEM_CHAIN_BY_ORIGIN;
}

/** Maps template EVM origins to {@link TEvmChainFrom} for {@link Builder.from}. */
export function toSdkEvmFrom(chain: EvmChain): TEvmChainFrom {
  if (chain === "Moonbeam" || chain === "Moonriver" || chain === "Darwinia" || chain === "Ethereum") {
    return chain;
  }
  /* SNOWBRIDGE_FEATURE */
  if (chain === "EthereumTestnet") {
    return "Ethereum";
  }
  /* END_SNOWBRIDGE_FEATURE */
  throw new Error(`Unsupported EVM origin: ${chain}`);
}

export const VIEM_CHAIN_BY_ORIGIN: Partial<Record<TChain, Chain>> = {
  Moonbeam: moonbeam,
  Moonriver: moonriver,
  Darwinia: darwinia,
  /* SNOWBRIDGE_FEATURE */
  Ethereum: mainnet,
  EthereumTestnet: sepolia,
  /* END_SNOWBRIDGE_FEATURE */
};

export type EvmChain = keyof typeof VIEM_CHAIN_BY_ORIGIN;

/** Origin chains available for the current wallet type in the transfer form. */
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
      "No EVM wallet found. Install MetaMask or another EIP-1193 provider.",
    );
  }
  return window.ethereum;
}

const isUnrecognizedChainError = (error: unknown): boolean =>
  typeof error === "object" &&
  error !== null &&
  "code" in error &&
  (error as { code: number }).code === 4902;

const getAddEthereumChainParams = (chain: Chain) => ({
  chainId: numberToHex(chain.id),
  chainName: chain.name,
  nativeCurrency: chain.nativeCurrency,
  rpcUrls: chain.rpcUrls.default.http,
  blockExplorerUrls: chain.blockExplorers?.default?.url
    ? [chain.blockExplorers.default.url]
    : undefined,
});

/** Prompt the injected wallet to switch to the network for the selected origin. */
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
    if (!isUnrecognizedChainError(error)) {
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
  const account = walletClient.account;
  const address =
    typeof account === "string" ? account : account?.address;

  if (!address) {
    throw new Error(
      "MetaMask wallet has no account. Disconnect and connect again.",
    );
  }

  await switchWalletToOrigin(origin);

  return createWalletClient({
    account: address as Address,
    chain: getViemChainForOrigin(origin),
    transport: custom(getEthereumProvider()),
  });
}
