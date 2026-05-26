/* EVM_FEATURE — entire file (replaces `usePjsWallet` + `PjsWalletControls` exports when EVM is enabled) */

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
  UseWalletWithEvmReturn,
} from "../shared/types";
import { PjsWalletControls } from "./PjsWalletControls";
import { usePjsWallet } from "./usePjsWallet";

export type UseWalletReturn = UseWalletWithEvmReturn;

export const WalletControls = createWalletControls(PjsWalletControls);

export function useWalletWithEvm(): UseWalletReturn {
  const pjs = usePjsWallet();

  const toSubstratePayload = useCallback(
    (connection: SubstrateWalletConnection) => ({
      signer: connection.signer as Signer,
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
        return;
      }

      /* EVM_FEATURE */
      if (await submitEvmIfNeeded(formValues, options)) {
        return;
      }
      /* END_EVM_FEATURE */

      if (options.kind !== "substrate") {
        return;
      }

      await submitUsingSdk(
        formValues,
        options.signer as Signer,
        options.senderAddress,
      );
    },
    [core],
  );

  return { ...core, submitTransfer };
}
