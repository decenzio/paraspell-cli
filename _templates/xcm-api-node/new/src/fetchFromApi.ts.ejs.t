---
to: src/fetchFromApi.ts
---
import axios from "axios";
<% if (evmWallet) { -%>
import type { Hex } from "viem";
<% } -%>
import { API_URL } from "./consts.js";
import type { ApiParams, ApiTransaction } from "./types.js";

type ApiErrorResponse = {
  message?: string;
};

export const fetchFromApi = async (
  params: ApiParams,
): Promise<ApiTransaction[]> => {
  try {
    const response = await axios.post(`${API_URL}/x-transfers`, params);
    return response.data as ApiTransaction[];
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
    const response = await axios.post(`${API_URL}/evm-x-transfer`, params);
    return response.data as Hex;
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
