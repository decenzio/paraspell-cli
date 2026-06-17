---
to: src/wallet/shared/types.ts
skip_if: <%= (!evmWallet).toString() %>
---
import type { ComputedRef, Ref } from "vue";
import type { EIP1193Provider } from "mipd";
import type { WalletClient } from "viem";
import type { FormValues } from "../../types";
import type { WalletKind } from "../evm/WalletKindSelector.vue";
import type { EvmAccountOption } from "../evm/useEvmWallet";

export type WalletAccountOption = {
  address: string;
  name?: string;
};

export type SubstrateWalletConnection<TSigner> = {
  address: string;
  signer: TSigner;
};

export type SubstrateWalletBase<TSigner> = {
  extensionNames: Ref<string[]> | string[];
  selectedExtensionName: Ref<string | undefined> | string | undefined;
  accounts: Ref<WalletAccountOption[]> | WalletAccountOption[];
  selectedAddress: Ref<string | undefined> | string | undefined;
  connection:
    | Ref<SubstrateWalletConnection<TSigner> | null>
    | SubstrateWalletConnection<TSigner>
    | null;
  discoverExtensions: () => Promise<void>;
  selectExtension: (name: string) => Promise<void>;
  selectAccountByAddress: (address: string) => void;
};

export type WalletSubmitOptions<TSigner = unknown> =
  | { kind: "evm"; walletClient: WalletClient; provider: EIP1193Provider }
  | { kind: "substrate"; signer: TSigner; senderAddress: string };

export type UseWalletWithEvmReturn<TSigner = unknown> = SubstrateWalletBase<TSigner> & {
  activeWalletKind: Ref<WalletKind>;
  setActiveWalletKind: (kind: WalletKind) => void;
  buildSubmitOptions: (from: string) => WalletSubmitOptions<TSigner> | null;
  submitTransfer: (formValues: FormValues) => Promise<boolean>;
  evmAccounts: ComputedRef<EvmAccountOption[]>;
  connectEvm: () => Promise<void>;
  selectEvmAccount: (address: string) => void;
  disconnectEvm: () => void;
  getEvmWalletClient: (origin: string) => WalletClient | undefined;
};

export type WalletControlsSubstrateProps = {
  extensionNames: string[];
  selectedExtensionName: string | undefined;
  accounts: WalletAccountOption[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onExtensionChange: (name: string) => void;
  onAccountChange: (address: string) => void;
};
