---
to: src/wallet/pjs/usePjsWallet.ts
skip_if: <%= (client !== 'pjs').toString() %>
---
import { useCallback, useEffect, useMemo, useState } from "react";
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
  const [extensionNames, setExtensionNames] = useState<string[]>([]);
  const [selectedExtensionName, setSelectedExtensionName] = useState<
    string | null
  >(null);
  const [accounts, setAccounts] = useState<ExtensionAccount[]>([]);
  const [selectedAddress, setSelectedAddress] = useState<string>();
  const [signer, setSigner] = useState<ExtensionInjectedSigner | null>(null);

  const discoverExtensions = useCallback(async () => {
    const injected = await web3Enable(DAPP_ORIGIN);
    if (!injected.length) {
      alert(
        "No Polkadot{.js} extension responded. Install a compatible wallet.",
      );
      return;
    }
    setExtensionNames(injected.map((e) => e.name));
    setSelectedExtensionName(null);
    setAccounts([]);
    setSelectedAddress(undefined);
    setSigner(null);
  }, []);

  const selectExtension = useCallback(async (name: string) => {
    await web3Enable(DAPP_ORIGIN);
    const filtered = await web3Accounts({ extensions: [name] });
    const nextAccounts = filtered.map(
      (account: InjectedAccount): ExtensionAccount => ({
        address: account.address,
        name: account.meta.name,
      }),
    );
    setSelectedExtensionName(name);
    setAccounts(nextAccounts);
    if (nextAccounts[0]) {
      setSelectedAddress(nextAccounts[0].address);
    } else {
      setSelectedAddress(undefined);
    }
  }, []);

  /** Keep extensions authorized when the selected account changes. */
  useEffect(() => {
    if (!selectedAddress) {
      return;
    }
    void web3Enable(DAPP_ORIGIN);
  }, [selectedAddress]);

  useEffect(() => {
    if (!selectedAddress) {
      return;
    }
    let cancelled = false;
    void web3FromAddress(selectedAddress)
      .then((injector) => {
        if (cancelled) return;
        setSigner(injector.signer);
      })
      .catch(() => {
        if (!cancelled) setSigner(null);
      });
    return () => {
      cancelled = true;
      setSigner(null);
    };
  }, [selectedAddress]);

  const connection = useMemo((): PjsWalletConnection | null => {
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
