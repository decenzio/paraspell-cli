import { onMounted, ref } from "vue";
import {
  fetchExchangeChains,
  getExchangeChains,
} from "./exchangeChains";

const chains = ref<readonly string[]>(getExchangeChains());

export const useExchangeChains = () => {
  onMounted(() => {
    void fetchExchangeChains().then((result) => {
      chains.value = result;
    });
  });

  return { chains };
};
