---
to: src/evm.ts
skip_if: <%= (!evmWallet).toString() %>
---
export { isEvmOrigin } from "./evmOrigins.js";
<%- h.includeShared('shared/node/getEvmWalletClient.ejs.t') %>
<%- h.includeShared('shared/node/getEvmSenderAddress.ejs.t') %>
