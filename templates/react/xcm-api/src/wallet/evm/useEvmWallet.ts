/* EVM_FEATURE — entire file */

import { useCallback, useEffect, useMemo, useState } from "react";
import type { Address, WalletClient } from "viem";
import { createWalletClient, custom } from "viem";
import {
  getEthereumProvider,
  getViemChainForOrigin,
} from "../../evm/evmWalletClient";

export type EvmAccountOption = {
  address: string;
  label: string;
};

const truncateAddress = (address: string) =>
  `${address.slice(0, 6)}…${address.slice(-4)}`;

export function useEvmWallet() {
  const [accounts, setAccounts] = useState<string[]>([]);
  const [selectedAddress, setSelectedAddress] = useState<string>();

  useEffect(() => {
    if (!window.ethereum) return;

    const provider = window.ethereum;
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
  }, []);

  const accountOptions = useMemo((): EvmAccountOption[] => {
    return accounts.map((address) => ({
      address,
      label: truncateAddress(address),
    }));
  }, [accounts]);

  const connect = useCallback(async () => {
    try {
      const provider = getEthereumProvider();
      const requestedAccounts = (await provider.request({
        method: "eth_requestAccounts",
      })) as string[];

      if (requestedAccounts.length === 0) {
        alert("No accounts found in the connected wallet.");
        return;
      }

      setAccounts(requestedAccounts);
      setSelectedAddress(requestedAccounts[0]);
    } catch {
      alert(
        "Failed to connect. Install MetaMask or another EIP-1193 wallet and try again.",
      );
    }
  }, []);

  const selectAccountByAddress = useCallback((address: string) => {
    setSelectedAddress(address);
  }, []);

  const disconnect = useCallback(() => {
    setAccounts([]);
    setSelectedAddress(undefined);
  }, []);

  const getWalletClient = useCallback(
    (origin: string): WalletClient | undefined => {
      if (!selectedAddress) return undefined;

      return createWalletClient({
        account: selectedAddress as Address,
        transport: custom(getEthereumProvider()),
        chain: getViemChainForOrigin(origin),
      });
    },
    [selectedAddress],
  );

  return {
    accounts: accountOptions,
    selectedAddress,
    connect,
    selectAccountByAddress,
    disconnect,
    getWalletClient,
  };
}
