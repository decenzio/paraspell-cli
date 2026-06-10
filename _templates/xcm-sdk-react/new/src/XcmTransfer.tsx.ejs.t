---
to: src/XcmTransfer.tsx
---
import { useCallback, useState, type FC } from "react";
import TransferForm from "./XcmTransferForm";
import type { FormValues } from "./types";
import type { TChain } from "@paraspell/sdk";
import {
  <% if (evm) { %>useWallet,
  WalletControls,
  WalletKindSelector,<% } else if (client === 'pjs') { %>
  usePjsWallet,
  PjsWalletControls,<% } else if (client === 'papi') { %>
  usePapiWallet,
  PapiWalletControls,<% } else { %>
  useDedotWallet,
  DedotWalletControls,<% } %>
} from "./wallet/<%= clientDir %>";<% if (!evm) { %>
import { submitUsingSdk } from "./xcm/<%= client %>";<% } -%>

const toError = (error: unknown): Error =>
  error instanceof Error ? error : new Error("An unknown error occurred");

const XcmTransfer: FC = () => {
  const [errorVisible, setErrorVisible] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);

  <% if (evm) { %>const wallet = useWallet();<% } else if (client === 'pjs') { %>const wallet = usePjsWallet();<% } else if (client === 'papi') { %>const wallet = usePapiWallet();<% } else { %>const wallet = useDedotWallet();<% } %>
  const [originChain, setOriginChain] = useState<TChain>("Astar");

  <% if (evm) { %>const handleOriginChange = useCallback((origin: TChain) => {
    setOriginChain(origin);
  }, []);

  const setWalletKind = useCallback(
    (kind: typeof wallet.activeWalletKind) => {
      wallet.setActiveWalletKind(kind);
    },
    [wallet],
  );<% } else { %>const handleOriginChange = useCallback((origin: TChain) => {
    setOriginChain(origin);
  }, []);<% } %>

  const onSubmit = async (formValues: FormValues) => {
    setLoading(true);
    setErrorVisible(false);

    try {
      <% if (evm) { %>const submitted = await wallet.submitTransfer(formValues);
      if (!submitted) return;<% } else { %>if (!wallet.connection) {
        alert("No account selected, connect wallet first");
        return;
      }

      <% if (client === 'papi') { %>await submitUsingSdk(
        formValues,
        wallet.connection.signer,
        wallet.connection.address,
      );<% } else { %>await submitUsingSdk(
        formValues,
        wallet.connection.signer,
        wallet.connection.address,
      );<% } %><% } %>
      alert("Transaction was successful!");
    } catch (error) {
      setError(toError(error));
      setErrorVisible(true);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="transferLayout">
      <% if (evm) { %>
      <div className="formHeader">
        <WalletKindSelector
          activeWalletKind={wallet.activeWalletKind}
          setActiveWalletKind={setWalletKind}
        />
        <WalletControls wallet={wallet} />
      </div>
      <% } else if (client === 'pjs') { %>
      <div className="formHeader">
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
      </div>
      <% } else if (client === 'papi') { %>
      <div className="formHeader">
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
      </div>
      <% } else { %>
      <div className="formHeader">
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
      </div>
      <% } %>
      <TransferForm
        onSubmit={onSubmit}
        loading={loading}
        originChain={originChain}
        onOriginChange={handleOriginChange}
      />
      {errorVisible && <p className="transferError">{error?.message}</p>}
    </div>
  );
};

export default XcmTransfer;
