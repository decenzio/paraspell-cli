---
to: src/wallet/shared/types.ts
skip_if: <%= (!evm).toString() %>
---
/* EVM_FEATURE — entire file */

import type { WalletClient } from "viem";
import type { FormValues } from "../../types";
import type { WalletKind } from "../evm/WalletKindSelector";
import type { EvmAccountOption } from "../evm/useEvmWallet";

export type WalletAccountOption = {
  address: string;
  name?: string;
};

export type SubstrateWalletConnection = {
  address: string;
  signer: unknown;
};

export type SubstrateWalletBase = {
  extensionNames: string[];
  selectedExtensionName: string | null;
  accounts: WalletAccountOption[];
  selectedAddress: string | undefined;
  connection: SubstrateWalletConnection | null;
  discoverExtensions: () => Promise<void>;
  selectExtension: (name: string) => Promise<void>;
  selectAccountByAddress: (address: string) => void;
};

export type WalletSubmitOptions =
  | { kind: "evm"; walletClient: WalletClient }
  | { kind: "substrate"; signer: unknown; senderAddress: string };

export type UseWalletWithEvmReturn = SubstrateWalletBase & {
  activeWalletKind: WalletKind;
  setActiveWalletKind: (kind: WalletKind) => void;
  buildSubmitOptions: (from: string) => WalletSubmitOptions | null;
  getOriginMismatchError: (from: string) => string | null;
  submitTransfer: (formValues: FormValues) => Promise<void>;
  evmAccounts: EvmAccountOption[];
  connectEvm: () => Promise<void>;
  selectEvmAccount: (address: string) => void;
  disconnectEvm: () => void;
  getEvmWalletClient: (origin: string) => WalletClient | undefined;
};

export type WalletControlsSubstrateProps = {
  extensionNames: string[];
  selectedExtensionName: string | null;
  accounts: WalletAccountOption[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onExtensionChange: (name: string) => void;
  onAccountChange: (address: string) => void;
};
