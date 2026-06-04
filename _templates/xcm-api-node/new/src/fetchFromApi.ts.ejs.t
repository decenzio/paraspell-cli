---
to: src/fetchFromApi.ts
---
import axios from "axios";
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
