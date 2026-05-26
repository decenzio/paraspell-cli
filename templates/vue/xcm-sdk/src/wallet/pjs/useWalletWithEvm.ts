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
import PjsWalletControls from "./PjsWalletControls.vue";
import { usePjsWallet } from "./usePjsWallet";

export type UseWalletReturn = UseWalletWithEvmReturn;

export const WalletControls = createWalletControls(PjsWalletControls);

export function useWalletWithEvm(): UseWalletReturn {
  const pjs = usePjsWallet();

  const toSubstratePayload = (connection: SubstrateWalletConnection) => ({
    signer: connection.signer as Signer,
    senderAddress: connection.address,
  });

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

  const submitTransfer = async (formValues: FormValues) => {
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
  };

  return { ...core, submitTransfer };
}
