---
to: src/XcmTransferForm.tsx
---
import axios from "axios";
import { useState, useMemo, FormEvent, FC, useEffect } from "react";
import { API_URL } from "./consts";
import type { AssetInfo, FormValues } from "./types";

type Props = {
  onSubmit: (values: FormValues) => void;
  loading: boolean;
  originChain: string;
  onOriginChange: (origin: string) => void;
};

const TransferForm: FC<Props> = ({
  onSubmit,
  loading,
  originChain,
  onOriginChange,
}) => {
  const [chains, setChains] = useState<string[]>([]);
  const [destinationChain, setDestinationChain] = useState("Hydration");
  const [supportedAssets, setSupportedAssets] = useState<AssetInfo[]>([]);
  const [currencyOptionId, setCurrencyOptionId] = useState("");
  <% if (swap) { %>const [currencyTo, setCurrencyTo] = useState("DOT");
  const [swapEnabled, setSwapEnabled] = useState(false);
  const [exchange, setExchange] = useState("");
  <% } %>const [recipient, setRecipient] = useState(
    "5F5586mfsnM6durWRLptYt3jSUs55KEmahdodQ5tQMr9iY96",
  );
  const [amount, setAmount] = useState("5");

  useEffect(() => {
    const fetchChains = async () => {
      const response = await axios.get(`${API_URL}/chains`);
      setChains(response.data);
    };
    void fetchChains();
  }, []);

  useEffect(() => {
    const fetchAssets = async () => {
      const response = await axios.get(
        `${API_URL}/supported-assets?origin=${originChain}&destination=${destinationChain}`,
      );
      const assets = response.data as AssetInfo[];
      setSupportedAssets(assets);
    };
    void fetchAssets();
  }, [originChain, destinationChain]);

  const currencyMap = useMemo(
    () =>
      supportedAssets.reduce(
        (map: Record<string, AssetInfo>, asset: AssetInfo) => {
          const key = `${asset.symbol ?? "NO_SYMBOL"}-${JSON.stringify(asset.location)}`;
          map[key] = asset;
          return map;
        },
        {},
      ),
    [supportedAssets],
  );

  const currencyOptions = useMemo(
    () =>
      Object.keys(currencyMap).map((key) => ({
        value: key,
        label: `${currencyMap[key].symbol ?? "Unknown"} - ${currencyMap[key].assetId ?? "Location"}`,
      })),
    [currencyMap],
  );

  const selectedCurrencyOptionId = currencyOptions.some(
    (option) => option.value === currencyOptionId,
  )
    ? currencyOptionId
    : currencyOptions.at(-1)?.value;

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!selectedCurrencyOptionId) return;

    onSubmit({
      from: originChain,
      to: destinationChain,
      recipient,
      amount,
      currency: currencyMap[selectedCurrencyOptionId],<% if (swap) { %>
      swapEnabled,
      currencyTo: swapEnabled ? currencyTo : undefined,
      exchange: swapEnabled && exchange ? exchange : undefined,<% } %>
    });
  };

  const chainOptions = chains;

  return (
    <form onSubmit={handleSubmit}>
      <label>
        Origin chain
        <select
          value={originChain}
          onChange={(e) => onOriginChange(e.target.value)}
          disabled={loading}
          required
        >
          {chainOptions.map((chain) => (
            <option key={chain} value={chain}>
              {chain}
            </option>
          ))}
        </select>
      </label>

      <label>
        Destination chain
        <select
          value={destinationChain}
          onChange={(e) => setDestinationChain(e.target.value)}
          disabled={loading}
          required
        >
          {chains.map((chain) => (
            <option key={chain} value={chain}>
              {chain}
            </option>
          ))}
        </select>
      </label>

      <label>
        Currency
        <select
          value={selectedCurrencyOptionId}
          onChange={(e) => setCurrencyOptionId(e.target.value)}
          required
        >
          {currencyOptions.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      </label>

      <label>
        Recipient address
        <input
          type="text"
          value={recipient}
          onChange={(e) => setRecipient(e.target.value)}
          required
        />
      </label>

      <label>
        Amount
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          required
        />
      </label>

      <% if (swap) { %>
      <>
          <button
            type="button"
            className="secondary"
            onClick={() => setSwapEnabled((prev) => !prev)}
          >
            {swapEnabled ? "- Remove Swap" : "+ Add Swap"}
          </button>

          {swapEnabled && (
            <>
              <label>
                Exchange
                <input
                  type="text"
                  value={exchange}
                  onChange={(e) => setExchange(e.target.value)}
                  placeholder="Leave empty for auto"
                />
              </label>

              <label>
                Currency To
                <input
                  type="text"
                  value={currencyTo}
                  onChange={(e) => setCurrencyTo(e.target.value)}
                  required
                />
              </label>
            </>
          )}
        </>
      <% } %>

      <button type="submit" disabled={loading}>
        {loading ? "Submitting..." : "Submit transaction"}
      </button>
    </form>
  );
};

export default TransferForm;
