---
to: src/fetchFromApi.ts
---
import axios from "axios";
import { API_URL } from "./consts";
import type { ApiParams, ApiTransaction } from "./types";

type ApiErrorResponse = {
  message?: string;
};

export const fetchFromApi = async (
  params: ApiParams,
): Promise<ApiTransaction[]> => {
  try {
    const response = await axios(`${API_URL}/x-transfers`, {
      method: "POST",
      data: params,
    });

    return response.data as ApiTransaction[];
  } catch (error) {
    if (axios.isAxiosError<ApiErrorResponse>(error)) {
      let errorMessage = "Error while fetching data.";
      if (error.response === undefined) {
        errorMessage += " Couldn't connect to API.";
      } else {
        const message = error.response.data.message;
        if (message) {
          errorMessage += ` Server response: ${message}`;
        }
      }
      throw new Error(errorMessage, { cause: error });
    } else if (error instanceof Error) {
      throw new Error(error.message, { cause: error });
    } else {
      throw new Error("An unknown error occurred", { cause: error });
    }
  }
};
