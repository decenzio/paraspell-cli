---
to: src/wallet/pjs/usePjsWallet.ts
skip_if: <%= (client !== 'pjs').toString() %>
---
import { computed, ref, watch } from "vue";
import {
  web3Accounts,
  web3Enable,
  web3FromAddress,
} from "@polkadot/extension-dapp";
import type { Injected } from "@polkadot/extension-inject/types";

type InjectedAccount = Awaited<ReturnType<typeof web3Accounts>>[number];

export type ExtensionAccount = {
  address: string;
  name?: string;
};

export type ExtensionInjectedSigner = Injected["signer"];

export type PjsWalletConnection = {
  address: string;
  signer: ExtensionInjectedSigner;
};

const DAPP_ORIGIN = "ParaSpell XCM SDK";

export function usePjsWallet() {
  const extensionNames = ref<string[]>([]);
  const selectedExtensionName = ref<string | null>(null);
  const accounts = ref<ExtensionAccount[]>([]);
  const selectedAddress = ref<string>();
  const signer = ref<ExtensionInjectedSigner | null>(null);

  const discoverExtensions = async () => {
    const injected = await web3Enable(DAPP_ORIGIN);
    if (!injected.length) {
      alert(
        "No Polkadot{.js} extension responded. Install a compatible wallet.",
      );
      return;
    }
    extensionNames.value = injected.map((e) => e.name);
    selectedExtensionName.value = null;
    accounts.value = [];
    selectedAddress.value = undefined;
    signer.value = null;
  };

  const selectExtension = async (name: string) => {
    await web3Enable(DAPP_ORIGIN);
    const filtered = await web3Accounts({ extensions: [name] });
    const nextAccounts = filtered.map(
      (account: InjectedAccount): ExtensionAccount => ({
        address: account.address,
        name: account.meta.name,
      }),
    );
    selectedExtensionName.value = name;
    accounts.value = nextAccounts;
    selectedAddress.value = nextAccounts[0]?.address;
  };

  watch(selectedAddress, (address) => {
    if (!address) return;
    void web3Enable(DAPP_ORIGIN);
  });

  watch(
    selectedAddress,
    (address, _, onCleanup) => {
      if (!address) return;
      let cancelled = false;
      onCleanup(() => {
        cancelled = true;
        signer.value = null;
      });
      void web3FromAddress(address)
        .then((injector) => {
          if (!cancelled) signer.value = injector.signer;
        })
        .catch(() => {
          if (!cancelled) signer.value = null;
        });
    },
    { immediate: true },
  );

  const connection = computed((): PjsWalletConnection | null => {
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
