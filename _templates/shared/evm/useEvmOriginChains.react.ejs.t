import { useCallback, useEffect, useRef, useState } from "react";
import { loadEvmOriginChains } from "./evmOrigins";

export const useEvmOriginChains = () => {
  const [chains, setChains] = useState<readonly string[]>([]);
  const chainsRef = useRef(chains);
  chainsRef.current = chains;
  const fetchPromiseRef = useRef<Promise<readonly string[]> | null>(null);

  const ensureEvmOriginChains = useCallback(async (): Promise<readonly string[]> => {
    if (chainsRef.current.length > 0) {
      return chainsRef.current;
    }

    fetchPromiseRef.current ??= loadEvmOriginChains();
    try {
      const result = await fetchPromiseRef.current;
      setChains(result);
      return result;
    } finally {
      fetchPromiseRef.current = null;
    }
  }, []);

  useEffect(() => {
    void ensureEvmOriginChains();
  }, [ensureEvmOriginChains]);

  const isEvmOrigin = useCallback(
    (chain: string) => chains.includes(chain),
    [chains],
  );

  return { chains, isEvmOrigin, ensureEvmOriginChains };
};
