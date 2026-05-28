import { useCallback, useState, type FC } from "react";
import TransferForm from "./XcmTransferForm";
import type { FormValues } from "./types";
import { getOriginChainsForWallet, isChainEvm } from "./evm";
import {
  useWallet,
  WalletControls,
  WalletKindSelector,
} from "./wallet/papi";

const XcmTransfer: FC = () => {
  const [errorVisible, setErrorVisible] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);

  const wallet = useWallet();
  const [originChain, setOriginChain] = useState("Astar");

  const handleOriginChange = useCallback(
    (origin: string) => {
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
  );

  const onSubmit = async (formValues: FormValues) => {
    setLoading(true);
    setErrorVisible(false);

    try {
      const mismatch = wallet.getOriginMismatchError(formValues.from);
      if (mismatch) {
        setError(new Error(mismatch));
        setErrorVisible(true);
        return;
      }

      await wallet.submitTransfer(formValues);
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
      <div className="formHeader">
        <WalletKindSelector
          activeWalletKind={wallet.activeWalletKind}
          setActiveWalletKind={setWalletKind}
        />
        <WalletControls wallet={wallet} />
      </div>
      <TransferForm
        onSubmit={onSubmit}
        loading={loading}
        originChain={originChain}
        onOriginChange={handleOriginChange}
        isEvmOrigin={wallet.activeWalletKind === "evm"}
      />
      {errorVisible && <p className="transferError">{error?.message}</p>}
    </div>
  );
};

export default XcmTransfer;
