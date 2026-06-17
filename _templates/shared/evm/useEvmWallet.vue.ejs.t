import { computed, onMounted, onUnmounted, ref } from "vue";
import type { EIP6963ProviderDetail } from "mipd";
import { getAddress, type WalletClient, isAddress } from "viem";
import { createWalletClient, custom } from "viem";
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
  const providers = ref<readonly EIP6963ProviderDetail[]>(getEip6963Providers());
  const accounts = ref<string[]>([]);
  const selectedAddress = ref<string>();
  const selectedProvider = ref<EIP6963ProviderDetail>();

  let unsubscribe: (() => void) | undefined;

  onMounted(() => {
    unsubscribe = evmProviderStore?.subscribe((nextProviders) => {
      providers.value = nextProviders;
    });
  });

  onUnmounted(() => {
    unsubscribe?.();
  });

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

  const accountOptions = computed((): EvmAccountOption[] =>
    accounts.value.map((address) => ({
      address,
      label: truncateAddress(address),
    })),
  );

  const connectWithProvider = async (providerDetail: EIP6963ProviderDetail) => {
    const provider = providerDetail.provider;
    const requestedAccounts = parseRequestedAccounts(
      await provider.request({ method: "eth_requestAccounts" }),
    );

    if (requestedAccounts.length === 0) {
      alert("No accounts found in the connected wallet.");
      return;
    }

    selectedProvider.value = providerDetail;
    accounts.value = requestedAccounts;
    selectedAddress.value = requestedAccounts[0];
    provider.on?.("accountsChanged", handleAccountsChanged);
  };

  const connect = async () => {
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
  };

  const selectAccountByAddress = (address: string) => {
    selectedAddress.value = address;
  };

  const disconnect = () => {
    const provider = selectedProvider.value?.provider;
    provider?.removeListener?.("accountsChanged", handleAccountsChanged);
    accounts.value = [];
    selectedAddress.value = undefined;
    selectedProvider.value = undefined;
  };

  const getWalletClient = (origin: string): WalletClient | undefined => {
    if (!selectedAddress.value || !selectedProvider.value) return undefined;
    if (!isAddress(selectedAddress.value)) {
      throw new Error("Selected EVM address is invalid.");
    }

    return createWalletClient({
      account: getAddress(selectedAddress.value),
      transport: custom(selectedProvider.value.provider),
      chain: getViemChainForOrigin(origin),
    });
  };

  const getConnectedWalletClient = (origin: string): WalletClient | undefined => {
    if (!selectedProvider.value) return undefined;
    return createEvmWalletClient(origin, selectedProvider.value.provider);
  };

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
