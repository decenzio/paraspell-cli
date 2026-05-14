import type { FC } from "react";
import type { DedotStyleAccount } from "./useDedotWallet";

export type DedotWalletControlsProps = {
  extensionNames: string[];
  selectedExtensionName: string | null;
  accounts: DedotStyleAccount[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onExtensionChange: (name: string) => void;
  onAccountChange: (address: string) => void;
};

export const DedotWalletControls: FC<
DedotWalletControlsProps
> = ({
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
        <h4>Select extension (injectedWeb3):</h4>
        <select
          value={selectedExtensionName ?? ""}
          onChange={(e) => onExtensionChange(e.target.value)}
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
        Discover extensions (injectedWeb3)
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
