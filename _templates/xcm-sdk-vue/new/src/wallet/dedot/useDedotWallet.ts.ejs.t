---
to: src/wallet/dedot/useDedotWallet.ts
skip_if: <%= (client !== 'dedot').toString() %>
---
import { computed, ref } from "vue";
import type { Signer } from "@polkadot/api/types";

export type ExtensionInjectedSigner = Signer;

export type DedotAccount = { address: string; name?: string };

type WindowWithInjectedWeb3 = Window & {
  injectedWeb3?: Record<
    string,
    {
      enable: (dappName?: string) => Promise<{
        signer: ExtensionInjectedSigner;
        accounts: { get: () => Promise<DedotAccount[]> };
      }>;
    }
  >;
};

function getInjectedWeb3() {
  if (typeof window === "undefined") return undefined;

  return (window as WindowWithInjectedWeb3).injectedWeb3;
}

export type DedotWalletConnection = {
  address: string;
  signer: ExtensionInjectedSigner;
};

export function useDedotWallet() {
  const extensionNames = ref<string[]>([]);
  const selectedExtensionName = ref<string>();
  const signer = ref<ExtensionInjectedSigner | null>(null);
  const accounts = ref<DedotAccount[]>([]);
  const selectedAddress = ref<string>();

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

  const discoverExtensions = async () => {
    const raw = getInjectedWeb3();
    const names = Object.keys(raw ?? {}).filter((n) => raw?.[n]);
    if (names.length === 0) {
      alert("No window.injectedWeb3 extensions found.");
      throw new Error("No injectedWeb3 extensions");
    }
    extensionNames.value = names;
    await selectExtension(names[0]);
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
