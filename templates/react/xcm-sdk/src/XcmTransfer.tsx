import { useCallback, useState, type FC } from "react";
import TransferForm from "./XcmTransferForm";
import type { FormValues } from "./types";
import type { TChain } from "@paraspell/sdk";
/* EVM_FEATURE */
import { getOriginChainsForWallet, isChainEvm } from "./evm";
/* END_EVM_FEATURE */

// Switch SDK stack by changing these imports together:
import { useWallet, WalletControls, WalletKindSelector } from "./wallet/pjs";
// import { useWallet, WalletControls, WalletKindSelector } from "./wallet/papi";
// import { useWallet, WalletControls, WalletKindSelector } from "./wallet/dedot";

const XcmTransfer: FC = () => {
  const [errorVisible, setErrorVisible] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);

  const wallet = useWallet();
  const [originChain, setOriginChain] = useState<TChain>("Astar");

  /* EVM_FEATURE */
  const handleOriginChange = useCallback(
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
  );
  /* END_EVM_FEATURE */

  const onSubmit = async (formValues: FormValues) => {
    setLoading(true);
    setErrorVisible(false);

    try {
      /* EVM_FEATURE */
      const mismatch = wallet.getOriginMismatchError(formValues.from);
      if (mismatch) {
        setError(new Error(mismatch));
        setErrorVisible(true);
        return;
      }

      await wallet.submitTransfer(formValues);
      /* END_EVM_FEATURE */
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
      {/* EVM_FEATURE */}
      <WalletKindSelector
        activeWalletKind={wallet.activeWalletKind}
        setActiveWalletKind={setWalletKind}
      />
      <WalletControls wallet={wallet} />
      {/* END_EVM_FEATURE */}
      <TransferForm
        onSubmit={onSubmit}
        loading={loading}
        originChain={originChain}
        onOriginChange={handleOriginChange}
        isEvmOrigin={wallet.activeWalletKind === "evm"}
      />
      {errorVisible && <p>{error?.message}</p>}
    </div>
  );
};

export default XcmTransfer;
