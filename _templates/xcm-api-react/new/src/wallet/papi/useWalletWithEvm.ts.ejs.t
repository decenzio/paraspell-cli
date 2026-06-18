---
to: src/wallet/papi/useWalletWithEvm.ts
skip_if: <%= (!evmWallet).toString() %>
---
import { useCallback } from "react";
import type { PolkadotSigner } from "polkadot-api";
import type { FormValues } from "../../types";
import { submitUsingApi } from "../../submit/submitUsingApi";
import { createWalletControls } from "../shared/createWalletControls";
import { connectWalletAlert } from "../shared/submitTransfer";
import { useWalletWithEvmCore } from "../shared/useWalletWithEvmCore";
import type {
  SubstrateWalletConnection,
  UseWalletReturn,
} from "../../types";
import { PapiWalletControls } from "./PapiWalletControls";
import { usePapiWallet } from "./usePapiWallet";
import type { PapiWalletConnection } from "../../types";

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

      await submitUsingApi(formValues, options);
      return true;
    },
    [core],
  );

  return { ...core, submitTransfer };
}
