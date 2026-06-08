---
to: src/wallet/dedot/useDedotWallet.ts
skip_if: <%= (client !== 'dedot').toString() %>
---
import { useCallback, useMemo, useState } from "react";
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
  const [extensionNames, setExtensionNames] = useState<string[]>([]);
  const [selectedExtensionName, setSelectedExtensionName] = useState<string>();
  const [signer, setSigner] = useState<ExtensionInjectedSigner | null>(null);
  const [accounts, setAccounts] = useState<DedotAccount[]>([]);
  const [selectedAddress, setSelectedAddress] = useState<string>();

  const selectExtension = useCallback(async (name: string) => {
    const entry = getInjectedWeb3()?.[name];
    if (!entry) {
      alert("Extension not available");
      return;
    }
    const injected = await entry.enable("ParaSpell XCM SDK");
    setSigner(injected.signer);
    setSelectedExtensionName(name);
    const accs = await injected.accounts.get();
    setAccounts(accs);
    if (accs[0]) setSelectedAddress(accs[0].address);
    else setSelectedAddress(undefined);
  }, []);

  const discoverExtensions = useCallback(async () => {
    const raw = getInjectedWeb3();
    const names = Object.keys(raw ?? {}).filter((n) => raw?.[n]);
    if (names.length === 0) {
      alert("No window.injectedWeb3 extensions found.");
      throw new Error("No injectedWeb3 extensions");
    }
    setExtensionNames(names);
    await selectExtension(names[0]);
  }, [selectExtension]);

  const connection = useMemo((): DedotWalletConnection | null => {
    if (!selectedAddress || !signer) return null;
    return { address: selectedAddress, signer };
  }, [selectedAddress, signer]);

  const selectAccountByAddress = useCallback(
    (address: string) => {
      const acc = accounts.find((a) => a.address === address);
      if (acc) setSelectedAddress(acc.address);
    },
    [accounts],
  );

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
