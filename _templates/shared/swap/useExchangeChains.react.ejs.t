import { useEffect, useState } from "react";
import {
  fetchExchangeChains,
  getExchangeChains,
} from "./exchangeChains";

export const useExchangeChains = () => {
  const [chains, setChains] = useState<readonly string[]>(getExchangeChains);

  useEffect(() => {
    void fetchExchangeChains().then(setChains);
  }, []);

  return { chains };
};
