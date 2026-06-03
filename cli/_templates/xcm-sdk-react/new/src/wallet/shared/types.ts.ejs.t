---
to: src/wallet/shared/types.ts
skip_if: <%= (!evm).toString() %>
---
import type { TChain } from "<%= sdkPackage %>";
import type { WalletClient } from "viem";
import type { FormValues } from "../../types";
import type { WalletKind } from "../evm/WalletKindSelector";
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
  | { kind: "evm"; walletClient: WalletClient }
  | { kind: "substrate"; signer: TSigner; senderAddress: string };

export type UseWalletWithEvmReturn<TSigner = unknown> = SubstrateWalletBase<TSigner> & {
  activeWalletKind: WalletKind;
  setActiveWalletKind: (kind: WalletKind) => void;
  buildSubmitOptions: (from: TChain) => WalletSubmitOptions<TSigner> | null;
  getOriginMismatchError: (from: TChain) => string | null;
  submitTransfer: (formValues: FormValues) => Promise<void>;
  evmAccounts: EvmAccountOption[];
  connectEvm: () => Promise<void>;
  selectEvmAccount: (address: string) => void;
  disconnectEvm: () => void;
  getEvmWalletClient: (origin: TChain) => WalletClient | undefined;
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
