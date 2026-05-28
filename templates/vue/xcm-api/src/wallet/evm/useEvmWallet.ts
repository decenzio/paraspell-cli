import { computed, onMounted, onUnmounted, ref } from "vue";
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
  const accounts = ref<string[]>([]);
  const selectedAddress = ref<string>();

  const handleAccountsChanged = (nextAccounts: string[]) => {
    if (nextAccounts.length === 0) {
      accounts.value = [];
      selectedAddress.value = undefined;
      return;
    }
    accounts.value = nextAccounts;
    const current = selectedAddress.value;
    selectedAddress.value =
      current && nextAccounts.includes(current) ? current : nextAccounts[0];
  };

  onMounted(() => {
    if (!window.ethereum) return;
    const provider = window.ethereum;
    provider.on?.("accountsChanged", handleAccountsChanged);
  });

  onUnmounted(() => {
    if (!window.ethereum) return;
    window.ethereum.removeListener?.("accountsChanged", handleAccountsChanged);
  });

  const accountOptions = computed((): EvmAccountOption[] =>
    accounts.value.map((address) => ({
      address,
      label: truncateAddress(address),
    })),
  );

  const connect = async () => {
    try {
      const provider = getEthereumProvider();
      const requestedAccounts = (await provider.request({
        method: "eth_requestAccounts",
      })) as string[];

      if (requestedAccounts.length === 0) {
        alert("No accounts found in the connected wallet.");
        return;
      }

      accounts.value = requestedAccounts;
      selectedAddress.value = requestedAccounts[0];
    } catch {
      alert(
        "Failed to connect. Install MetaMask or another EIP-1193 wallet and try again.",
      );
    }
  };

  const selectAccountByAddress = (address: string) => {
    selectedAddress.value = address;
  };

  const disconnect = () => {
    accounts.value = [];
    selectedAddress.value = undefined;
  };

  const getWalletClient = (origin: string): WalletClient | undefined => {
    if (!selectedAddress.value) return undefined;

    return createWalletClient({
      account: selectedAddress.value as Address,
      transport: custom(getEthereumProvider()),
      chain: getViemChainForOrigin(origin),
    });
  };

  return {
    accounts: accountOptions,
    selectedAddress,
    connect,
    selectAccountByAddress,
    disconnect,
    getWalletClient,
  };
}
