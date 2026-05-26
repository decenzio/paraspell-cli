---
to: src/wallet/evm/WalletKindSelector.tsx
skip_if: <%= (!evm).toString() %>
---
/* EVM_FEATURE — entire file */

import type { FC } from "react";

export type WalletKind = "substrate" | "evm";

export type WalletKindSelectorProps = {
  activeWalletKind: WalletKind;
  setActiveWalletKind: (kind: WalletKind) => void;
};

const WALLET_KIND_OPTIONS: { value: WalletKind; label: string }[] = [
  { value: "substrate", label: "Substrate" },
  { value: "evm", label: "EVM" },
];

export const WalletKindSelector: FC<WalletKindSelectorProps> = ({
  activeWalletKind,
  setActiveWalletKind,
}) => (
  <div>
    <h4>Wallet type:</h4>
    <select
      value={activeWalletKind}
      onChange={(e) => setActiveWalletKind(e.target.value as WalletKind)}
    >
      {WALLET_KIND_OPTIONS.map(({ value, label }) => (
        <option key={value} value={value}>
          {label}
        </option>
      ))}
    </select>
  </div>
);
