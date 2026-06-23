import axios from "axios";
import { API_URL } from "<% if (framework === 'node') { %>./consts.js<% } else { %>../consts<% } %>";

let cachedExchangeChains: readonly string[] = [];
let fetchPromise: Promise<readonly string[]> | null = null;

export const fetchExchangeChains = async (): Promise<readonly string[]> => {
  if (cachedExchangeChains.length > 0) {
    return cachedExchangeChains;
  }

  if (fetchPromise) {
    return fetchPromise;
  }

  fetchPromise = axios
    .get<string[]>(`${API_URL}/swap/exchange-chains`)
    .then((response) => {
      cachedExchangeChains = response.data;
      return cachedExchangeChains;
    })
    .finally(() => {
      fetchPromise = null;
    });

  return fetchPromise;
};

export const getExchangeChains = (): readonly string[] => cachedExchangeChains;
