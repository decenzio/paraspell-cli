---
to: src/wallet/dedot/useWalletWithEvm.ts
skip_if: <%= (!(evmWallet && client === 'dedot')).toString() %>
---
import { useCallback } from "react";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../../types";
import { submitUsingSdk } from "../../xcm/dedot";
import { createWalletControls } from "../shared/createWalletControls";
import {
  connectWalletAlert,
  submitEvmIfNeeded,
} from "../shared/submitTransfer";
import { useWalletWithEvmCore } from "../shared/useWalletWithEvmCore";
import type { UseWalletReturn } from "../../types";
import { DedotWalletControls } from "./DedotWalletControls";
import { useDedotWallet } from "./useDedotWallet";

export const WalletControls = createWalletControls(DedotWalletControls);

export const useWalletWithEvm = (): UseWalletReturn => {
  const dedot = useDedotWallet();

  const core = useWalletWithEvmCore<Signer>({
    extensionNames: dedot.extensionNames,
    selectedExtensionName: dedot.selectedExtensionName,
    accounts: dedot.accounts,
    selectedAddress: dedot.selectedAddress,
    connection: dedot.connection,
    discoverExtensions: dedot.discoverExtensions,
    selectExtension: dedot.selectExtension,
    selectAccountByAddress: dedot.selectAccountByAddress,
  });

  const submitTransfer = useCallback(
    async (formValues: FormValues) => {
      const options = core.buildSubmitOptions(formValues.from);
      if (!options) {
        connectWalletAlert(core);
        return false;
      }

      if (await submitEvmIfNeeded(formValues, options)) {
        return true;
      }

      await submitUsingSdk(formValues, options);
      return true;
    },
    [core],
  );

  return { ...core, submitTransfer };
};
