---
to: src/wallet/dedot/useWalletWithEvm.ts
skip_if: <%= (!(evm && client === 'dedot')).toString() %>
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
import type {
  SubstrateWalletConnection,
  UseWalletWithEvmReturn,
} from "../shared/types";
import { DedotWalletControls } from "./DedotWalletControls";
import { useDedotWallet } from "./useDedotWallet";

export type UseWalletReturn = UseWalletWithEvmReturn;

export const WalletControls = createWalletControls(DedotWalletControls);

export function useWalletWithEvm(): UseWalletReturn {
  const dedot = useDedotWallet();

  const toSubstratePayload = useCallback(
    (connection: SubstrateWalletConnection) => ({
      signer: connection.signer as Signer,
      senderAddress: connection.address,
    }),
    [],
  );

  const core = useWalletWithEvmCore(
    {
      extensionNames: dedot.extensionNames,
      selectedExtensionName: dedot.selectedExtensionName,
      accounts: dedot.accounts,
      selectedAddress: dedot.selectedAddress,
      connection: dedot.connection,
      discoverExtensions: dedot.discoverExtensions,
      selectExtension: dedot.selectExtension,
      selectAccountByAddress: dedot.selectAccountByAddress,
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

      if (await submitEvmIfNeeded(formValues, options)) {
        return;
      }

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
