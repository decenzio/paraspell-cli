---
to: src/evm/evmWalletClient.ts
skip_if: <%= (!evm).toString() %>
---
<%- h.includeShared('shared/evm/evmWalletClient.api.ejs.t') %>
