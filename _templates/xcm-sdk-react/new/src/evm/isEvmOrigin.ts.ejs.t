---
to: src/evm/isEvmOrigin.ts
skip_if: <%= (!evmWallet).toString() %>
---
<%- h.includeShared('shared/evm/isEvmOrigin.sdk.ejs.t') %>
