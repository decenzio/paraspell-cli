import { useState, useEffect, FormEvent, FC } from "react";
import useCurrencyOptions from "./useCurrencyOptions-base";
import {
  CHAINS,
  SUBSTRATE_CHAINS,
  TChain,
  TSubstrateChain,
} from "@paraspell/sdk";
import type { FormValues } from "./types-base";

type Props = {
  onSubmit: (values: FormValues) => void;
  loading: boolean;
};

const TransferForm: FC<Props> = ({ onSubmit, loading }) => {
  // Prepare states for the form fields
  const [originChain, setOriginChain] = useState<TSubstrateChain>("Astar");
  const [destinationChain, setDestinationChain] = useState<TChain>("Hydration");
  const [currencyOptionId, setCurrencyOptionId] = useState("");
  const [recipient, setRecipient] = useState(
    "5F5586mfsnM6durWRLptYt3jSUs55KEmahdodQ5tQMr9iY96",
  );
  const [amount, setAmount] = useState("5");

  // Get currency options based on the selected chains
  const { currencyOptions, currencyMap} =
    useCurrencyOptions(originChain, destinationChain);

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

  return (
    <form onSubmit={handleSubmit}>
      <label>
        Origin chain
        <select
          value={originChain}
          onChange={(e) => setOriginChain(e.target.value as TSubstrateChain)}
          required
        >
          {SUBSTRATE_CHAINS.map((chain) => (
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

      <button type="submit" disabled={loading}>
        {loading ? "Submitting..." : "Submit transaction"}
      </button>
    </form>
  );
};

export default TransferForm;
