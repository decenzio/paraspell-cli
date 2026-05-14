import { useState, type FC } from "react";
import TransferForm from "./XcmTransferForm";
import type { FormValues } from "./types";
import { submitUsingSdk } from "./xcm/dedot";
import { WalletControls } from "./wallet/dedot";
import { useWallet } from "./wallet/dedot";

//imports

const XcmTransfer: FC = () => {
  const [errorVisible, setErrorVisible] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);

  const wallet = useWallet();

  const onSubmit = async (formValues: FormValues) => {
    if (!wallet.connection) {
      alert("No account selected, connect wallet first");
      return;
    }

    setLoading(true);
    const { address, signer } = wallet.connection;

    try {
      await submitUsingSdk(formValues, signer, address);
      alert("Transaction was successful!");
    } catch (e) {
      setError(e as Error);
      setErrorVisible(true);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <WalletControls
        extensionNames={wallet.extensionNames}
        selectedExtensionName={wallet.selectedExtensionName}
        accounts={wallet.accounts}
        selectedAddress={wallet.selectedAddress}
        onConnectClick={() => {
          wallet.discoverExtensions();
        }}
        onExtensionChange={(name) => {
          wallet.selectExtension(name);
        }}
        onAccountChange={wallet.selectAccountByAddress}
      />
      <TransferForm onSubmit={onSubmit} loading={loading} />
      <div>{errorVisible && <p>{error?.message}</p>}</div>
    </div>
  );
};

export default XcmTransfer;
