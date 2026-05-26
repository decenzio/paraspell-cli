import { useState, useEffect, useMemo, FormEvent, FC } from "react";
import useCurrencyOptions from "./useCurrencyOptions";
import {
  CHAINS,
  EXCHANGE_CHAINS,
  TChain,
  TExchangeChain,
} from "@paraspell/sdk";
import type { FormValues } from "./types";
/* EVM_FEATURE */
import { getOriginChainsForWallet } from "./evm";
/* END_EVM_FEATURE */

type Props = {
  onSubmit: (values: FormValues) => void;
  originChain: TChain;
  onOriginChange: (origin: TChain) => void;
  isEvmOrigin?: boolean;
  loading: boolean;
};

const TransferForm: FC<Props> = ({
  onSubmit,
  originChain,
  onOriginChange,
  isEvmOrigin = false,
  loading,
}) => {
  const [destinationChain, setDestinationChain] = useState<TChain>("Hydration");
  const [currencyOptionId, setCurrencyOptionId] = useState("");
  const [currencyToOptionId, setCurrencyToOptionId] = useState("");
  const [swapEnabled, setSwapEnabled] = useState(false);
  const [exchange, setExchange] = useState<TExchangeChain | undefined>(
    undefined,
  );
  const [recipient, setRecipient] = useState(
    "5F5586mfsnM6durWRLptYt3jSUs55KEmahdodQ5tQMr9iY96",
  );
  const [amount, setAmount] = useState("5");

  /* EVM_FEATURE */
  const originChains = useMemo(
    () => getOriginChainsForWallet(isEvmOrigin),
    [isEvmOrigin],
  );

  /* END_EVM_FEATURE */

  // Get currency options based on the selected chains
  const { currencyOptions, currencyMap, currencyToOptions, currencyToMap } =
    useCurrencyOptions(originChain, destinationChain, swapEnabled, exchange);

  // Handle form submission
  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const transformedValues = {
      from: originChain,
      to: destinationChain,
      currencyOptionId,
      recipient,
      amount,
      // Get the selected currency based on the currency option id
      currency: currencyMap[currencyOptionId],
      /* SWAP FEATURE */
      swapEnabled,
      currencyTo: swapEnabled ? currencyToMap[currencyToOptionId] : undefined,
      /* END SWAP FEATURE */
      exchange,
    };

    // Pass the submitted form values to the parent component
    onSubmit(transformedValues);
  };

  useEffect(() => {
    // Set default currency option if available
    if (currencyOptions.length > 0) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setCurrencyOptionId(currencyOptions[currencyOptions.length - 1].value);
    }
  }, [currencyOptions]);

  useEffect(() => {
    // Set default destination currency option if available
    if (currencyToOptions.length > 0) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setCurrencyToOptionId(
        currencyToOptions[currencyToOptions.length - 1].value,
      );
    }
  }, [currencyToOptions]);

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
          {originChains.map((chain) => (
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
          value={currencyOptionId}
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
      </label>

      /* SWAP FEATURE */
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
              value={exchange ?? ""}
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
              value={currencyToOptionId}
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
      )}
      /* END SWAP FEATURE */

      <button type="submit" disabled={loading}>
        {loading ? "Submitting..." : "Submit transaction"}
      </button>
    </form>
  );
};

export default TransferForm;
