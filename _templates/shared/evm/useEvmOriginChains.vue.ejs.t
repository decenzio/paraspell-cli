import { onMounted, ref } from "vue";
import {
  fetchEvmOriginChains,
  getEvmOriginChains,
  isEvmOrigin,
} from "./evmOrigins";

export const useEvmOriginChains = () => {
  const chains = ref<readonly string[]>(getEvmOriginChains());

  onMounted(() => {
    void fetchEvmOriginChains().then((result) => {
      chains.value = result;
    });
  });

  return { chains, isEvmOrigin };
};
