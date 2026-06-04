---
to: src/wallet/evm/EvmWalletControls.tsx
skip_if: <%= (!evm).toString() %>
---
import type { FC } from "react";
import type { EvmAccountOption } from "./useEvmWallet";

export type EvmWalletControlsProps = {
  accounts: EvmAccountOption[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onAccountChange: (address: string) => void;
  onDisconnect?: () => void;
};

export const EvmWalletControls: FC<EvmWalletControlsProps> = ({
  accounts,
  selectedAddress,
  onConnectClick,
  onAccountChange,
  onDisconnect,
}) => (
  <>
    {accounts.length === 0 ? (
      <button type="button" onClick={onConnectClick}>
        Connect Wallet
      </button>
    ) : (
      <div>
        <h4>Select account:</h4>
        <select
          value={selectedAddress}
          onChange={(e) => onAccountChange(e.target.value)}
        >
          {accounts.map(({ label, address }) => (
            <option key={address} value={address}>
              {label} — {address}
            </option>
          ))}
        </select>
      </div>
    )}
    {selectedAddress && onDisconnect && (
      <button type="button" className="secondary" onClick={onDisconnect}>
        Disconnect
      </button>
    )}
  </>
);
