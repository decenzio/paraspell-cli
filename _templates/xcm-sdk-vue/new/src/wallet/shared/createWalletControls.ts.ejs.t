---
to: src/wallet/shared/createWalletControls.ts
skip_if: <%= (!evm).toString() %>
---
import { defineComponent, h, unref, type Component, type PropType } from "vue";
import EvmWalletControls from "../evm/EvmWalletControls.vue";
import type { UseWalletWithEvmReturn, WalletControlsSubstrateProps } from "./types";

export function createWalletControls(SubstrateControls: Component) {
  return defineComponent({
    name: "WalletControls",
    props: {
      wallet: {
        type: Object as PropType<UseWalletWithEvmReturn>,
        required: true,
      },
    },
    setup(props) {
      return () => {
        const wallet = props.wallet;
        if (unref(wallet.activeWalletKind) === "evm") {
          return h(EvmWalletControls, {
            accounts: unref(wallet.evmAccounts),
            selectedAddress: unref(wallet.selectedAddress),
            onConnectClick: wallet.connectEvm,
            onAccountChange: wallet.selectEvmAccount,
            onDisconnect: wallet.disconnectEvm,
          });
        }

        const substrateProps: WalletControlsSubstrateProps = {
          extensionNames: unref(wallet.extensionNames),
          selectedExtensionName: unref(wallet.selectedExtensionName),
          accounts: unref(wallet.accounts),
          selectedAddress: unref(wallet.selectedAddress),
          onConnectClick: () => {
            void wallet.discoverExtensions();
          },
          onExtensionChange: (name: string) => {
            void wallet.selectExtension(name);
          },
          onAccountChange: wallet.selectAccountByAddress,
        };

        return h(SubstrateControls, substrateProps);
      };
    },
  });
}
