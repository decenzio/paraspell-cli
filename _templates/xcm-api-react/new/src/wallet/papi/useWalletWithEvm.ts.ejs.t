---
to: src/wallet/papi/useWalletWithEvm.ts
skip_if: <%= (!evm).toString() %>
---
import { useCallback } from "react";
import type { PolkadotSigner } from "polkadot-api";
import type { FormValues } from "../../types";
import { submitUsingApi } from "../../submit/submitUsingApi";
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
import { usePapiWallet, type PapiWalletConnection } from "./usePapiWallet";

export type UseWalletReturn = UseWalletWithEvmReturn<PolkadotSigner>;

export const WalletControls = createWalletControls(PapiWalletControls);

export function useWalletWithEvm(): UseWalletReturn {
  const papi = usePapiWallet();

  const toSubstratePayload = useCallback(
    (
      connection:
        | SubstrateWalletConnection<PolkadotSigner>
        | PapiWalletConnection,
    ) => ({
      signer: connection.signer,
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
        return false;
      }

      if (await submitEvmIfNeeded(formValues, options)) {
        return true;
      }

      if (options.kind !== "substrate") {
        return false;
      }

      await submitUsingApi(
        formValues,
        options.signer,
        options.senderAddress,
      );
      return true;
    },
    [core],
  );

  return { ...core, submitTransfer };
}
