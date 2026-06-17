import { useCallback, useEffect, useMemo, useState } from "react";
import { useSyncExternalStore } from "react";
import type { EIP6963ProviderDetail } from "mipd";
import { getAddress, type WalletClient } from "viem";
import { createWalletClient, custom, isAddress } from "viem";
import { evmProviderStore, getEip6963Providers } from "../../evm/eip6963";
import { createEvmWalletClient } from "../../evm/evmWalletClient";
import { getViemChainForOrigin } from "../../evm/getViemChain";

export type EvmAccountOption = {
  address: string;
  label: string;
};

const truncateAddress = (address: string) =>
  `${address.slice(0, 6)}…${address.slice(-4)}`;

function parseRequestedAccounts(result: unknown): string[] {
  if (!Array.isArray(result)) {
    throw new Error("Wallet returned an invalid accounts response.");
  }
  return result.filter((value): value is string => typeof value === "string");
}

export function useEvmWallet() {
  const providers = useSyncExternalStore(
    (onStoreChange) => evmProviderStore?.subscribe(onStoreChange) ?? (() => undefined),
    () => getEip6963Providers(),
    () => [],
  );
  const [accounts, setAccounts] = useState<string[]>([]);
  const [selectedAddress, setSelectedAddress] = useState<string>();
  const [selectedProvider, setSelectedProvider] =
    useState<EIP6963ProviderDetail>();

  useEffect(() => {
    const provider = selectedProvider?.provider;
    if (!provider) return;

    const handleAccountsChanged = (nextAccounts: string[]) => {
      if (nextAccounts.length === 0) {
        setAccounts([]);
        setSelectedAddress(undefined);
        return;
      }
      setAccounts(nextAccounts);
      setSelectedAddress((current) =>
        current && nextAccounts.includes(current) ? current : nextAccounts[0],
      );
    };

    provider.on?.("accountsChanged", handleAccountsChanged);
    return () => {
      provider.removeListener?.("accountsChanged", handleAccountsChanged);
    };
  }, [selectedProvider]);

  const accountOptions = useMemo((): EvmAccountOption[] => {
    return accounts.map((address) => ({
      address,
      label: truncateAddress(address),
    }));
  }, [accounts]);

  const connectWithProvider = useCallback(
    async (providerDetail: EIP6963ProviderDetail) => {
      const provider = providerDetail.provider;
      const requestedAccounts = parseRequestedAccounts(
        await provider.request({ method: "eth_requestAccounts" }),
      );

      if (requestedAccounts.length === 0) {
        alert("No accounts found in the connected wallet.");
        return;
      }

      setSelectedProvider(providerDetail);
      setAccounts(requestedAccounts);
      setSelectedAddress(requestedAccounts[0]);
    },
    [],
  );

  const connect = useCallback(async () => {
    try {
      const availableProviders = getEip6963Providers();
      if (availableProviders.length === 0) {
        alert("No EVM-compatible wallet found. Install an EIP-1193 wallet and try again.");
        return;
      }

      if (availableProviders.length === 1) {
        await connectWithProvider(availableProviders[0]);
        return;
      }

      const labels = availableProviders
        .map((entry, index) => `${index + 1}. ${entry.info.name}`)
        .join("\n");
      const choice = window.prompt(
        `Select a wallet provider:\n${labels}\n\nEnter the provider number:`,
        "1",
      );
      if (!choice) return;

      const index = Number.parseInt(choice, 10) - 1;
      const providerDetail = availableProviders[index];
      if (!providerDetail) {
        alert("Invalid wallet provider selection.");
        return;
      }

      await connectWithProvider(providerDetail);
    } catch {
      alert(
        "Failed to connect. Install an EVM-compatible wallet (EIP-1193) and try again.",
      );
    }
  }, [connectWithProvider]);

  const selectAccountByAddress = useCallback((address: string) => {
    setSelectedAddress(address);
  }, []);

  const disconnect = useCallback(() => {
    setAccounts([]);
    setSelectedAddress(undefined);
    setSelectedProvider(undefined);
  }, []);

  const getWalletClient = useCallback(
    (origin: string): WalletClient | undefined => {
      if (!selectedAddress || !selectedProvider) return undefined;
      if (!isAddress(selectedAddress)) {
        throw new Error("Selected EVM address is invalid.");
      }

      return createWalletClient({
        account: getAddress(selectedAddress),
        transport: custom(selectedProvider.provider),
        chain: getViemChainForOrigin(origin),
      });
    },
    [selectedAddress, selectedProvider],
  );

  const getConnectedWalletClient = useCallback(
    (origin: string): WalletClient | undefined => {
      if (!selectedProvider) return undefined;
      return createEvmWalletClient(origin, selectedProvider.provider);
    },
    [selectedProvider],
  );

  return {
    accounts: accountOptions,
    providers,
    selectedAddress,
    selectedProvider,
    connect,
    connectWithProvider,
    selectAccountByAddress,
    disconnect,
    getWalletClient,
    getConnectedWalletClient,
  };
}
