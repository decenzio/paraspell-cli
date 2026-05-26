---
to: src/wallet/shared/submitTransfer.ts
skip_if: <%= (!evm).toString() %>
---
/* EVM_FEATURE — entire file */

import type { FormValues } from "../../types";
import { submitEvmTransferFromForm } from "../../xcm/evmTransfer";
import type { WalletKind } from "../evm/WalletKindSelector";
import type { WalletSubmitOptions } from "./types";

import { unref } from "vue";

export const connectWalletAlert = (wallet: {
  activeWalletKind: { value: WalletKind } | WalletKind;
}): void => {
  const kind = unref(wallet.activeWalletKind);
  alert(
    kind === "evm"
      ? "Connect EVM wallet provider first"
      : "No account selected, connect wallet first",
  );
};

export const submitEvmIfNeeded = async (
  formValues: FormValues,
  options: WalletSubmitOptions,
): Promise<boolean> => {
  if (options.kind !== "evm") return false;
  await submitEvmTransferFromForm(formValues, options.walletClient);
  return true;
};
