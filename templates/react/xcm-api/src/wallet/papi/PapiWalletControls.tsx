import type { FC } from "react";

type WalletAccountOption = {
  address: string;
  name?: string;
};

export type PapiWalletControlsProps = {
  extensionNames: string[];
  selectedExtensionName: string | null;
  accounts: WalletAccountOption[];
  selectedAddress: string | undefined;
  onConnectClick: () => void;
  onExtensionChange: (name: string) => void;
  onAccountChange: (address: string) => void;
};

export const PapiWalletControls: FC<PapiWalletControlsProps> = ({
  extensionNames,
  selectedExtensionName,
  accounts,
  selectedAddress,
  onConnectClick,
  onExtensionChange,
  onAccountChange,
}) => (
  <>
    {extensionNames.length > 0 ? (
      <div>
        <h4>Select extension:</h4>
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
        Connect Wallet
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
              {name} - {address}
            </option>
          ))}
        </select>
      </div>
    )}
  </>
);
