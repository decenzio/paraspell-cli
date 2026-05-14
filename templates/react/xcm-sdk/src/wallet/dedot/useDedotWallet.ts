import { useCallback, useMemo, useState } from "react";
import type { Injected } from "@polkadot/extension-inject/types";
export type ExtensionInjectedSigner = Injected["signer"];

type Enableresult = {
  signer: ExtensionInjectedSigner;
  accounts: {
    get: () => Promise<Array<{ address: string; name?: string }>>;
  };
};

type InjectedWeb3Entry = {
  enable: (dappName?: string) => Promise<Enableresult>;
};

function getInjectedWeb3():
  | Record<string, InjectedWeb3Entry | undefined>
  | undefined {
  if (typeof window === "undefined") return undefined;

  return (window as Window & {
    injectedWeb3?: Record<string, InjectedWeb3Entry | undefined>;
  }).injectedWeb3;
}

export type DedotStyleAccount = { address: string; name?: string };

/** Extension signer + address — no `polkadot-api` imports here. */
export type DedotWalletConnection = {
  address: string;
  signer: ExtensionInjectedSigner;
};

/**
 * `window.injectedWeb3` flow (Dedot docs style). Does not import or depend on `polkadot-api`.
 *
 * For the same wallet wiring as the ParaSpell XCM web app (shared PJS + Dedot path), use
 * {@link usePjsExtensionDappWallet} with `submitUsingSdk` from `../xcm/dedot` instead.
 */
export function useDedotWallet() {
  const [extensionNames, setExtensionNames] = useState<string[]>([]);
  const [selectedExtensionName, setSelectedExtensionName] = useState<
    string | null
  >(null);
  const [signer, setSigner] = useState<ExtensionInjectedSigner | null>(null);
  const [accounts, setAccounts] = useState<DedotStyleAccount[]>([]);
  const [selectedAddress, setSelectedAddress] = useState<string>();

  const discoverExtensions = useCallback(async () => {
    const raw = getInjectedWeb3();
    const names = Object.keys(raw ?? {}).filter((n) => raw?.[n]);
    if (names.length === 0) {
      alert("No window.injectedWeb3 extensions found.");
      throw new Error("No injectedWeb3 extensions");
    }
    setSelectedExtensionName(null);
    setSigner(null);
    setAccounts([]);
    setSelectedAddress(undefined);
    setExtensionNames(names);
  }, []);

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
