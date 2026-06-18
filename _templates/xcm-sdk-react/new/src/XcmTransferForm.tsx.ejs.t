---
to: src/XcmTransferForm.tsx
---
import { useState, FormEvent, FC } from "react";
import useCurrencyOptions from "./useCurrencyOptions";
import {
  CHAINS,<% if (swap) { %>
  EXCHANGE_CHAINS,
  type TExchangeChain,<% } %>
  type TChain,
} from "<%= sdkPackage %>";
import type { FormValues } from "./types";

type Props = {
  onSubmit: (values: FormValues) => void;
  originChain: TChain;
  onOriginChange: (origin: TChain) => void;
  loading: boolean;
};

const TransferForm: FC<Props> = ({
  onSubmit,
  originChain,
  onOriginChange,
  loading,
}) => {
  const [destinationChain, setDestinationChain] = useState<TChain>("Hydration");
  const [currencyOptionId, setCurrencyOptionId] = useState("");
  <% if (swap) { %>const [currencyToOptionId, setCurrencyToOptionId] = useState("");
  const [swapEnabled, setSwapEnabled] = useState(false);
  const [exchange, setExchange] = useState<TExchangeChain | undefined>(undefined);
  <% } %>const [recipient, setRecipient] = useState(
    "5F5586mfsnM6durWRLptYt3jSUs55KEmahdodQ5tQMr9iY96",
  );
  const [amount, setAmount] = useState("5");

  const { currencyOptions, currencyMap<% if (swap) { %>, currencyToOptions, currencyToMap<% } %> } =
    useCurrencyOptions(originChain, destinationChain<% if (swap) { %>, swapEnabled, exchange<% } %>);

  const selectedCurrencyOptionId = currencyOptions.some(
    (option) => option.value === currencyOptionId,
  )
    ? currencyOptionId
    : currencyOptions.at(-1)?.value;<% if (swap) { %>

  const selectedCurrencyToOptionId = currencyToOptions.some(
    (option) => option.value === currencyToOptionId,
  )
    ? currencyToOptionId
    : currencyToOptions.at(-1)?.value;<% } %>

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!selectedCurrencyOptionId) return;<% if (swap) { %>
    let selectedCurrencyTo;
    if (swapEnabled) {
      if (!selectedCurrencyToOptionId) return;
      selectedCurrencyTo = currencyToMap[selectedCurrencyToOptionId];
    }<% } %>

    onSubmit({
      from: originChain,
      to: destinationChain,
      currencyOptionId: selectedCurrencyOptionId,
      recipient,
      amount,
      currency: currencyMap[selectedCurrencyOptionId],<% if (swap) { %>
      swapEnabled,
      currencyTo: selectedCurrencyTo,
      exchange,<% } %>
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <label>
        Origin chain
        <select
          value={originChain}
          onChange={(e) => onOriginChange(e.target.value as TChain)}
          disabled={loading}
          required
        >
          {CHAINS.map((chain) => (
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
          onChange={(e) => setDestinationChain(e.target.value as TChain)}
          disabled={loading}
          required
        >
          {CHAINS.map((chain) => (
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
          {currencyOptions.map((currency) => (
            <option key={currency.value} value={currency.value}>
              {currency.label}
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
      </label><% if (swap) { %>

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
            <select
              value={exchange}
              onChange={(e) =>
                setExchange(
                  e.target.value
                    ? (e.target.value as TExchangeChain)
                    : undefined,
                )
              }
            >
              <option value="">Auto</option>
              {EXCHANGE_CHAINS.map((chain) => (
                <option key={chain} value={chain}>
                  {chain}
                </option>
              ))}
            </select>
          </label>

          <label>
            Currency To
            <select
              value={selectedCurrencyToOptionId}
              onChange={(e) => setCurrencyToOptionId(e.target.value)}
              required
            >
              {currencyToOptions.map((currency) => (
                <option key={currency.value} value={currency.value}>
                  {currency.label}
                </option>
              ))}
            </select>
          </label>
        </>
      )}<% } %>

      <button type="submit" disabled={loading}>
        {loading ? "Submitting..." : "Submit transaction"}
      </button>
    </form>
  );
};

export default TransferForm;
