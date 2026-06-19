import { onMounted, ref } from "vue";
import {
  fetchEvmOriginChains,
  getEvmOriginChains,
  isEvmOrigin,
} from "./evmOrigins";

const chains = ref<readonly string[]>(getEvmOriginChains());

export function useEvmOriginChains() {
  onMounted(() => {
    void fetchEvmOriginChains().then((result) => {
      chains.value = result;
    });
  });

  return { chains, isEvmOrigin };
}
