---
to: src/wallet/pjs/useWalletWithEvm.ts
skip_if: <%= (!(evmWallet && client === 'pjs')).toString() %>
---
import { useCallback } from "react";
import type { Signer } from "@polkadot/api/types";
import type { FormValues } from "../../types";
import { submitUsingSdk } from "../../xcm/pjs";
import { createWalletControls } from "../shared/createWalletControls";
import {
  connectWalletAlert,
  submitEvmIfNeeded,
} from "../shared/submitTransfer";
import { useWalletWithEvmCore } from "../shared/useWalletWithEvmCore";
import type {
  SubstrateWalletConnection,
  UseWalletReturn,
} from "../../types";
import { PjsWalletControls } from "./PjsWalletControls";
import { usePjsWallet } from "./usePjsWallet";
import type { PjsWalletConnection } from "../../types";

export const WalletControls = createWalletControls(PjsWalletControls);

export function useWalletWithEvm(): UseWalletReturn {
  const pjs = usePjsWallet();

  const toSubstratePayload = useCallback(
    (connection: SubstrateWalletConnection<Signer> | PjsWalletConnection) => ({
      signer: connection.signer,
      senderAddress: connection.address,
    }),
    [],
  );

  const core = useWalletWithEvmCore(
    {
      extensionNames: pjs.extensionNames,
      selectedExtensionName: pjs.selectedExtensionName,
      accounts: pjs.accounts,
      selectedAddress: pjs.selectedAddress,
      connection: pjs.connection,
      discoverExtensions: pjs.discoverExtensions,
      selectExtension: pjs.selectExtension,
      selectAccountByAddress: pjs.selectAccountByAddress,
    },
    toSubstratePayload,
  );

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
}
