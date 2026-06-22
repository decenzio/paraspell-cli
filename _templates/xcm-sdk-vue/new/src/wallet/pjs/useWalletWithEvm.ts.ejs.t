---
to: src/wallet/pjs/useWalletWithEvm.ts
skip_if: <%= (!(evmWallet && client === 'pjs')).toString() %>
---

import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../../types";
import { submitUsingSdk } from "../../xcm/pjs";
import { createWalletControls } from "../shared/createWalletControls";
import {
  connectWalletAlert,
  submitEvmIfNeeded,
} from "../shared/submitTransfer";
import { useWalletWithEvmCore } from "../shared/useWalletWithEvmCore";
import type { UseWalletReturn } from "../../types";
import PjsWalletControls from "./PjsWalletControls.vue";
import { usePjsWallet } from "./usePjsWallet";

export const WalletControls = createWalletControls(PjsWalletControls);

export const useWalletWithEvm = (): UseWalletReturn => {
  const pjs = usePjsWallet();

  const core = useWalletWithEvmCore<Signer>({
    extensionNames: pjs.extensionNames,
    selectedExtensionName: pjs.selectedExtensionName,
    accounts: pjs.accounts,
    selectedAddress: pjs.selectedAddress,
    connection: pjs.connection,
    discoverExtensions: pjs.discoverExtensions,
    selectExtension: pjs.selectExtension,
    selectAccountByAddress: pjs.selectAccountByAddress,
  });

  const submitTransfer = async (formValues: FormValues) => {
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
  };

  return { ...core, submitTransfer };
};
