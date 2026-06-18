import axios from "axios";
<% if (evmWallet) { -%>
import type { Hex } from "viem";
<% } -%>
import { API_URL } from "./consts<% if (framework === 'node') { %>.js<% } %>";
import type { ApiParams, ApiTransaction, ApiErrorResponse } from "./types<% if (framework === 'node') { %>.js<% } %>";

export const fetchFromApi = async (
  params: ApiParams,
): Promise<ApiTransaction[]> => {
  try {
    const response = await axios.post<% if (framework === 'node') { %><% } else { %><ApiTransaction[]><% } %>(`${API_URL}/x-transfers`, params);
    return <% if (framework === 'node') { %>response.data as ApiTransaction[]<% } else { %>response.data<% } %>;
  } catch (error) {
    if (axios.isAxiosError<ApiErrorResponse>(error)) {
      const message = error.response?.data.message;
      const serverMessage = message ? ` Server response: ${message}` : "";
      throw new Error(`Error while fetching data.${serverMessage}`, {
        cause: error,
      });
    }
    throw error;
  }
};
<% if (evmWallet) { -%>

export const fetchFromEvmApi = async (params: ApiParams): Promise<Hex> => {
  try {
    const response = await axios.post<% if (framework === 'node') { %><% } else { %><Hex><% } %>(`${API_URL}/evm-x-transfer`, params);
    return <% if (framework === 'node') { %>response.data as Hex<% } else { %>response.data<% } %>;
  } catch (error) {
    if (axios.isAxiosError<ApiErrorResponse>(error)) {
      const message = error.response?.data.message;
      const serverMessage = message ? ` Server response: ${message}` : "";
      throw new Error(`Error while fetching EVM transaction.${serverMessage}`, {
        cause: error,
      });
    }
    throw error;
  }
};
<% } %>
