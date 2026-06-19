import { useEffect, useState } from "react";
import {
  fetchEvmOriginChains,
  getEvmOriginChains,
  isEvmOrigin,
} from "./evmOrigins";

export function useEvmOriginChains() {
  const [chains, setChains] = useState<readonly string[]>(getEvmOriginChains);

  useEffect(() => {
    void fetchEvmOriginChains().then(setChains);
  }, []);

  return { chains, isEvmOrigin };
}
