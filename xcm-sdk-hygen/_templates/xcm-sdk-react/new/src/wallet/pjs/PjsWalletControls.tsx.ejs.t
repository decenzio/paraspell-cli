---
to: src/wallet/pjs/PjsWalletControls.tsx
skip_if: <%= (client !== 'pjs').toString() %>
---
import type { FC } from "react";
import type { ExtensionAccount } from "./usePjsWallet";

export type PjsWalletControlsProps = {
  extensionNames: string[];
  selectedExtensionName: string | null;
  accounts: ExtensionAccount[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onExtensionChange: (name: string) => void;
  onAccountChange: (address: string) => void;
};

/** UI for `usePjsExtensionDappWallet` — extension then account, aligned with PAPI controls. */
export const PjsWalletControls: FC<PjsWalletControlsProps> = ({
  extensionNames,
  selectedExtensionName,
  accounts,
  selectedAddress,
  onConnectClick,
  onExtensionChange,
  onAccountChange,
}) => (
  <div className="formHeader">
    {extensionNames.length > 0 ? (
      <div>
        <h4>Select extension:</h4>
        <select
          value={selectedExtensionName ?? ""}
          onChange={(e) => {
            const name = e.target.value;
            if (name) {
              void onExtensionChange(name);
            }
          }}
        >
          <option disabled value="">
            -- select an option --
          </option>
          {extensionNames.map((name) => (
            <option key={name} value={name}>
              {name}
            </option>
          ))}
        </select>
      </div>
    ) : (
      <button type="button" onClick={onConnectClick}>
        Connect Wallet (extension-dapp)
      </button>
    )}
    {accounts.length > 0 && (
      <div>
        <h4>Select account:</h4>
        <select
          value={selectedAddress ?? ""}
          onChange={(e) => onAccountChange(e.target.value)}
        >
          {accounts.map(({ name, address }) => (
            <option key={address} value={address}>
              {name ?? address} — {address}
            </option>
          ))}
        </select>
      </div>
    )}
  </div>
);
