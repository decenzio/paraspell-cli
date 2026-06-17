import type { EIP1193Provider } from "mipd";
import {
  createWalletClient,
  custom,
  type Address,
  type WalletClient,
} from "viem";
import { getViemChainForOrigin } from "./getViemChain";

export function createEvmWalletClient(
  origin: string,
  provider: EIP1193Provider,
): WalletClient {
  return createWalletClient({
    chain: getViemChainForOrigin(origin),
    transport: custom(provider),
  });
}

export async function ensureEvmWalletClient(
  walletClient: WalletClient,
  origin: string,
  provider: EIP1193Provider,
): Promise<WalletClient> {
  if (!walletClient.account) {
    throw new Error(
      "EVM wallet has no account. Disconnect and connect again.",
    );
  }
  const address: Address = walletClient.account.address;

  return createWalletClient({
    account: address,
    chain: getViemChainForOrigin(origin),
    transport: custom(provider),
  });
}
