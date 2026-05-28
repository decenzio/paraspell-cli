import axios, { AxiosError } from "axios";
import { API_URL } from "./consts.js";
import type { ApiParams, ApiTransaction } from "./types.js";

export const fetchFromApi = async (
  params: ApiParams,
): Promise<ApiTransaction[]> => {
  try {
    const response = await axios.post(`${API_URL}/x-transfers`, params);
    return response.data as ApiTransaction[];
  } catch (error) {
    if (error instanceof AxiosError) {
      const data = error.response?.data as { message?: unknown };
      const rawMessage = data?.message;
      const serverMessage = rawMessage
        ? ` Server response: ${
            typeof rawMessage === "string"
              ? rawMessage
              : JSON.stringify(rawMessage)
          }`
        : "";
      throw new Error(`Error while fetching data.${serverMessage}`, {
        cause: error,
      });
    }
    throw error;
  }
};
