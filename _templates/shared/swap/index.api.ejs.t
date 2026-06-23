export {
  fetchExchangeChains,
  getExchangeChains,
} from "./exchangeChains";
<% if (framework !== 'node') { -%>
export { useExchangeChains } from "./useExchangeChains";
<% } -%>
