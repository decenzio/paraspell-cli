---
to: src/wallet/papi/useWalletWithEvm.ts
skip_if: <%= (!(evmWallet && client === 'papi')).toString() %>
---

import type { PolkadotSigner } from "polkadot-api";
import type { FormValues } from "../../types";
import { submitUsingSdk } from "../../xcm/papi";
import { createWalletControls } from "../shared/createWalletControls";
import {
  connectWalletAlert,
  submitEvmIfNeeded,
} from "../shared/submitTransfer";
import { useWalletWithEvmCore } from "../shared/useWalletWithEvmCore";
import type { UseWalletReturn } from "../../types";
import PapiWalletControls from "./PapiWalletControls.vue";
import { usePapiWallet } from "./usePapiWallet";

export const WalletControls = createWalletControls(PapiWalletControls);

export const useWalletWithEvm = (): UseWalletReturn => {
  const papi = usePapiWallet();

  const core = useWalletWithEvmCore<PolkadotSigner>({
    extensionNames: papi.extensionNames,
    selectedExtensionName: papi.selectedExtensionName,
    accounts: papi.accounts,
    selectedAddress: papi.selectedAddress,
    connection: papi.connection,
    discoverExtensions: papi.discoverExtensions,
    selectExtension: papi.selectExtension,
    selectAccountByAddress: papi.selectAccountByAddress,
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
