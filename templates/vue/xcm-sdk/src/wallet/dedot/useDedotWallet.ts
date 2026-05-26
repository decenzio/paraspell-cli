import { computed, ref } from "vue";
import type { Injected } from "@polkadot/extension-inject/types";

export type ExtensionInjectedSigner = Injected["signer"];

type EnableResult = {
  signer: ExtensionInjectedSigner;
  accounts: {
    get: () => Promise<Array<{ address: string; name?: string }>>;
  };
};

type InjectedWeb3Entry = {
  enable: (dappName?: string) => Promise<EnableResult>;
};

function getInjectedWeb3():
  | Record<string, InjectedWeb3Entry | undefined>
  | undefined {
  if (typeof window === "undefined") return undefined;

  return (
    window as Window & {
      injectedWeb3?: Record<string, InjectedWeb3Entry | undefined>;
    }
  ).injectedWeb3;
}

export type DedotStyleAccount = { address: string; name?: string };

export type DedotWalletConnection = {
  address: string;
  signer: ExtensionInjectedSigner;
};

export function useDedotWallet() {
  const extensionNames = ref<string[]>([]);
  const selectedExtensionName = ref<string | null>(null);
  const signer = ref<ExtensionInjectedSigner | null>(null);
  const accounts = ref<DedotStyleAccount[]>([]);
  const selectedAddress = ref<string>();

  const discoverExtensions = async () => {
    const raw = getInjectedWeb3();
    const names = Object.keys(raw ?? {}).filter((n) => raw?.[n]);
    if (names.length === 0) {
      alert("No window.injectedWeb3 extensions found.");
      throw new Error("No injectedWeb3 extensions");
    }
    selectedExtensionName.value = null;
    signer.value = null;
    accounts.value = [];
    selectedAddress.value = undefined;
    extensionNames.value = names;
  };

  const selectExtension = async (name: string) => {
    const entry = getInjectedWeb3()?.[name];
    if (!entry) {
      alert("Extension not available");
      return;
    }
    const injected = await entry.enable("ParaSpell XCM SDK");
    signer.value = injected.signer;
    selectedExtensionName.value = name;
    const accs = await injected.accounts.get();
    accounts.value = accs;
    selectedAddress.value = accs[0]?.address;
  };

  const connection = computed((): DedotWalletConnection | null => {
    if (!selectedAddress.value || !signer.value) return null;
    return { address: selectedAddress.value, signer: signer.value };
  });

  const selectAccountByAddress = (address: string) => {
    const acc = accounts.value.find((a) => a.address === address);
    if (acc) selectedAddress.value = acc.address;
  };

  return {
    extensionNames,
    selectedExtensionName,
    accounts,
    selectedAddress,
    connection,
    discoverExtensions,
    selectExtension,
    selectAccountByAddress,
  };
}
