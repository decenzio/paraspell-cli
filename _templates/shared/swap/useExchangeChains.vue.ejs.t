import { onMounted, ref } from "vue";
import {
  fetchExchangeChains,
  getExchangeChains,
} from "./exchangeChains";

export const useExchangeChains = () => {
  const chains = ref<readonly string[]>(getExchangeChains());

  onMounted(() => {
    void fetchExchangeChains().then((result) => {
      chains.value = result;
    });
  });

  return { chains };
};
