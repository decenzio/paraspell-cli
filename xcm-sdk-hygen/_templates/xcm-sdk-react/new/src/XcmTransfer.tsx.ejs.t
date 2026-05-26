---
to: src/XcmTransfer.tsx
---
import { useCallback, useState, type FC } from "react";
import TransferForm from "./XcmTransferForm";
import type { FormValues } from "./types";
import type { TChain } from "@paraspell/sdk";<% if (evm) { %>
import { getOriginChainsForWallet, isChainEvm } from "./evm";<% } %>
import {
  useWallet,<% if (evm) { %>
  WalletControls,
  WalletKindSelector,<% } else if (client === 'pjs') { %>
  usePjsWallet,
  PjsWalletControls,<% } else if (client === 'papi') { %>
  usePapiWallet,
  PapiWalletControls,<% } else { %>
  useDedotWallet,
  DedotWalletControls,<% } %>
} from "./wallet/<%= clientDir %>";<% if (!evm) { %>
import { submitUsingSdk } from "./xcm/<%= client %>";<% if (client === 'pjs' || client === 'dedot') { %>
import type { Signer } from "@polkadot/api/types";<% } else { %>
import type { PolkadotSigner } from "polkadot-api";<% } %><% } %>

const XcmTransfer: FC = () => {
  const [errorVisible, setErrorVisible] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);

  <% if (evm) { %>const wallet = useWallet();<% } else if (client === 'pjs') { %>const wallet = usePjsWallet();<% } else if (client === 'papi') { %>const wallet = usePapiWallet();<% } else { %>const wallet = useDedotWallet();<% } %>
  const [originChain, setOriginChain] = useState<TChain>("Astar");

  <% if (evm) { %>const handleOriginChange = useCallback(
    (origin: TChain) => {
      setOriginChain(origin);
      wallet.setActiveWalletKind(isChainEvm(origin) ? "evm" : "substrate");
    },
    [wallet],
  );

  const setWalletKind = useCallback(
    (kind: typeof wallet.activeWalletKind) => {
      wallet.setActiveWalletKind(kind);
      const allowed = getOriginChainsForWallet(kind === "evm");
      if (!allowed.includes(originChain)) {
        setOriginChain(allowed[0]);
      }
    },
    [wallet, originChain],
  );<% } else { %>const handleOriginChange = useCallback((origin: TChain) => {
    setOriginChain(origin);
  }, []);<% } %>

  const onSubmit = async (formValues: FormValues) => {
    setLoading(true);
    setErrorVisible(false);

    try {
      <% if (evm) { %>const mismatch = wallet.getOriginMismatchError(formValues.from);
      if (mismatch) {
        setError(new Error(mismatch));
        setErrorVisible(true);
        return;
      }

      await wallet.submitTransfer(formValues);<% } else { %>if (!wallet.connection) {
        alert("No account selected, connect wallet first");
        return;
      }

      <% if (client === 'papi') { %>await submitUsingSdk(formValues, {
        kind: "substrate",
        signer: wallet.connection.signer as PolkadotSigner,
        senderAddress: wallet.connection.address,
      });<% } else { %>await submitUsingSdk(
        formValues,
        wallet.connection.signer as Signer,
        wallet.connection.address,
      );<% } %><% } %>
      alert("Transaction was successful!");
    } catch (e) {
      setError(e as Error);
      setErrorVisible(true);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="transferLayout">
      <% if (evm) { %>
      <WalletKindSelector
        activeWalletKind={wallet.activeWalletKind}
        setActiveWalletKind={setWalletKind}
      />
      <WalletControls wallet={wallet} />
      <% } else if (client === 'pjs') { %>
      <PjsWalletControls
        extensionNames={wallet.extensionNames}
        selectedExtensionName={wallet.selectedExtensionName}
        accounts={wallet.accounts}
        selectedAddress={wallet.selectedAddress}
        onConnectClick={() => {
          void wallet.discoverExtensions();
        }}
        onExtensionChange={(name) => {
          void wallet.selectExtension(name);
        }}
        onAccountChange={wallet.selectAccountByAddress}
      />
      <% } else if (client === 'papi') { %>
      <PapiWalletControls
        extensionNames={wallet.extensionNames}
        selectedExtensionName={wallet.selectedExtensionName}
        accounts={wallet.accounts}
        selectedAddress={wallet.selectedAddress}
        onConnectClick={() => {
          void wallet.discoverExtensions();
        }}
        onExtensionChange={(name) => {
          void wallet.selectExtension(name);
        }}
        onAccountChange={wallet.selectAccountByAddress}
      />
      <% } else { %>
      <DedotWalletControls
        extensionNames={wallet.extensionNames}
        selectedExtensionName={wallet.selectedExtensionName}
        accounts={wallet.accounts}
        selectedAddress={wallet.selectedAddress}
        onConnectClick={() => {
          void wallet.discoverExtensions();
        }}
        onExtensionChange={(name) => {
          void wallet.selectExtension(name);
        }}
        onAccountChange={wallet.selectAccountByAddress}
      />
      <% } %>
      <TransferForm
        onSubmit={onSubmit}
        loading={loading}
        originChain={originChain}
        onOriginChange={handleOriginChange}<% if (evm) { %>
        isEvmOrigin={wallet.activeWalletKind === "evm"}<% } %>
      />
      {errorVisible && <p className="transferError">{error?.message}</p>}
    </div>
  );
};

export default XcmTransfer;
