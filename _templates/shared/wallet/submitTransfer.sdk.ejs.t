import type { FormValues } from "../../types";
import { submitEvmTransferFromForm } from "../../xcm/evmTransfer";
import type { WalletKind, WalletSubmitOptions } from "../../types";

export const connectWalletAlert = (wallet: {
  activeWalletKind: WalletKind;
}): void => {
  alert(
    wallet.activeWalletKind === "evm"
      ? "Connect EVM wallet provider first"
      : "No account selected, connect wallet first",
  );
};

export const submitEvmIfNeeded = async (
  formValues: FormValues,
  options: WalletSubmitOptions,
): Promise<boolean> => {
  if (options.kind !== "evm") return false;
  await submitEvmTransferFromForm(
    formValues,
    options.walletClient,
    options.provider,
  );
  return true;
};
