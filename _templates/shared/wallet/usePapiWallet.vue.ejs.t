import { computed, ref } from "vue";
import {
  connectInjectedExtension,
  getInjectedExtensions,
  type InjectedExtension,
  type InjectedPolkadotAccount,
} from "polkadot-api/pjs-signer";
import type { PapiWalletConnection } from "../../types";

export function usePapiWallet() {
  const extensionNames = ref<string[]>([]);
  const selectedExtension = ref<InjectedExtension | null>(null);
  const accounts = ref<InjectedPolkadotAccount[]>([]);
  const selectedAccount = ref<InjectedPolkadotAccount>();

  const connection = computed((): PapiWalletConnection | null => {
    if (!selectedAccount.value) return null;
    return {
      address: selectedAccount.value.address,
      signer: selectedAccount.value.polkadotSigner,
    };
  });

  const selectExtension = async (name: string) => {
    const injected = await connectInjectedExtension(name);
    selectedExtension.value = injected;
    const nextAccounts = injected.getAccounts();
    accounts.value = nextAccounts;
    selectedAccount.value = nextAccounts[0];
  };

  const discoverExtensions = async () => {
    const names = getInjectedExtensions();
    if (names.length === 0) {
      alert("No wallet extension found, install it to connect");
      throw new Error("No Wallet Extension Found!");
    }
    extensionNames.value = names;
    await selectExtension(names[0]);
  };

  const selectAccountByAddress = (address: string) => {
    const acc = accounts.value.find((a) => a.address === address);
    if (acc) selectedAccount.value = acc;
  };

  return {
    extensionNames,
    selectedExtensionName: computed(() => selectedExtension.value?.name),
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
