---
to: src/wallet/papi/usePapiWallet.ts
skip_if: <%= (client !== 'papi').toString() %>
---
import { computed, ref } from "vue";
import {
  connectInjectedExtension,
  getInjectedExtensions,
  type InjectedExtension,
  type InjectedPolkadotAccount,
} from "polkadot-api/pjs-signer";
import type { PolkadotSigner } from "polkadot-api";

type ConnectedWallet = {
  address: string;
  signer: PolkadotSigner;
};

export function usePapiWallet() {
  const extensionNames = ref<string[]>([]);
  const selectedExtension = ref<InjectedExtension | null>(null);
  const accounts = ref<InjectedPolkadotAccount[]>([]);
  const selectedAccount = ref<InjectedPolkadotAccount>();

  const connection = computed((): ConnectedWallet | null => {
    if (!selectedAccount.value) return null;
    return {
      address: selectedAccount.value.address,
      signer: selectedAccount.value.polkadotSigner,
    };
  });

  const discoverExtensions = async () => {
    const names = getInjectedExtensions();
    if (names.length === 0) {
      alert("No wallet extension found, install it to connect");
      throw new Error("No Wallet Extension Found!");
    }
    extensionNames.value = names;
  };

  const selectExtension = async (name: string) => {
    const injected = await connectInjectedExtension(name);
    selectedExtension.value = injected;
    const nextAccounts = injected.getAccounts();
    accounts.value = nextAccounts;
    selectedAccount.value = nextAccounts[0];
  };

  const selectAccountByAddress = (address: string) => {
    const acc = accounts.value.find((a) => a.address === address);
    if (acc) selectedAccount.value = acc;
  };

  return {
    extensionNames,
    selectedExtensionName: computed(() => selectedExtension.value?.name ?? null),
    selectedExtension,
    accounts,
    selectedAddress: computed(() => selectedAccount.value?.address),
    selectedAccount,
    connection,
    discoverExtensions,
    selectExtension,
    selectAccountByAddress,
  };
}
