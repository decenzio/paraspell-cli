/* EVM_FEATURE — entire file (replaces `usePapiWallet` + `PapiWalletControls` exports when EVM is enabled) */

import { useCallback } from "react";
import type { PolkadotSigner } from "polkadot-api";
import type { FormValues } from "../../types";
import {
  submitUsingSdk,
  type SubmitOptions,
} from "../../xcm/papi";
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
import { PapiWalletControls } from "./PapiWalletControls";
import { usePapiWallet } from "./usePapiWallet";

export type UseWalletReturn = UseWalletWithEvmReturn;

export const WalletControls = createWalletControls(PapiWalletControls);

export function useWalletWithEvm(): UseWalletReturn {
  const papi = usePapiWallet();

  const toSubstratePayload = useCallback(
    (connection: SubstrateWalletConnection) => ({
      signer: connection.signer as PolkadotSigner,
      senderAddress: connection.address,
    }),
    [],
  );

  const core = useWalletWithEvmCore(
    {
      extensionNames: papi.extensionNames,
      selectedExtensionName: papi.selectedExtensionName,
      accounts: papi.accounts,
      selectedAddress: papi.selectedAddress,
      connection: papi.connection,
      discoverExtensions: papi.discoverExtensions,
      selectExtension: papi.selectExtension,
      selectAccountByAddress: papi.selectAccountByAddress,
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

      await submitUsingSdk(formValues, options as SubmitOptions);
    },
    [core],
  );

  return { ...core, submitTransfer };
}
