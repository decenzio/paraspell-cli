import axios from "axios";
import { API_URL } from "<% if (framework === 'node') { %>./consts.js<% } else { %>../consts<% } %>";

let cachedEvmOriginChains: readonly string[] = [];
let fetchPromise: Promise<readonly string[]> | null = null;

export async function fetchEvmOriginChains(): Promise<readonly string[]> {
  if (cachedEvmOriginChains.length > 0) {
    return cachedEvmOriginChains;
  }

  if (fetchPromise) {
    return fetchPromise;
  }

  fetchPromise = axios
    .get<string[]>(`${API_URL}/chains/evm`)
    .then((response) => {
      cachedEvmOriginChains = response.data;
      return cachedEvmOriginChains;
    })
    .finally(() => {
      fetchPromise = null;
    });

  return fetchPromise;
}

export function getEvmOriginChains(): readonly string[] {
  return cachedEvmOriginChains;
}

export function isEvmOrigin(chain: string): boolean {
  return getEvmOriginChains().includes(chain);
}
