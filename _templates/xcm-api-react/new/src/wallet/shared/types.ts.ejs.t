---
to: src/wallet/shared/types.ts
skip_if: <%= (!evmWallet).toString() %>
---
import type { EIP1193Provider } from "mipd";
import type { WalletClient } from "viem";
import type { FormValues } from "../../types";
import type { WalletKind } from "../evm/WalletKindSelector";
import type { EvmAccountOption, EvmProviderOption } from "../evm/useEvmWallet";

export type WalletAccountOption = {
  address: string;
  name?: string;
};

export type SubstrateWalletConnection<TSigner> = {
  address: string;
  signer: TSigner;
};

export type SubstrateWalletBase<TSigner> = {
  extensionNames: string[];
  selectedExtensionName: string | undefined;
  accounts: WalletAccountOption[];
  selectedAddress: string | undefined;
  connection: SubstrateWalletConnection<TSigner> | null;
  discoverExtensions: () => Promise<void>;
  selectExtension: (name: string) => Promise<void>;
  selectAccountByAddress: (address: string) => void;
};

export type WalletSubmitOptions<TSigner = unknown> =
  | { kind: "evm"; walletClient: WalletClient; provider: EIP1193Provider }
  | { kind: "substrate"; signer: TSigner; senderAddress: string };

export type UseWalletWithEvmReturn<TSigner = unknown> = SubstrateWalletBase<TSigner> & {
  activeWalletKind: WalletKind;
  setActiveWalletKind: (kind: WalletKind) => void;
  buildSubmitOptions: (from: string) => WalletSubmitOptions<TSigner> | null;
  submitTransfer: (formValues: FormValues) => Promise<boolean>;
  evmAccounts: EvmAccountOption[];
  evmProviderOptions: EvmProviderOption[];
  selectedEvmProviderUuid: string | undefined;
  discoverEvmProviders: () => Promise<void>;
  selectEvmProvider: (uuid: string) => Promise<void>;
  selectEvmAccount: (address: string) => void;
  disconnectEvm: () => void;
  getEvmWalletClient: (origin: string) => WalletClient | undefined;
};

export type WalletControlsEvmProps = {
  providerOptions: EvmProviderOption[];
  selectedProviderUuid: string | undefined;
  accounts: EvmAccountOption[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onProviderChange: (uuid: string) => void;
  onAccountChange: (address: string) => void;
  onDisconnect?: () => void;
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
