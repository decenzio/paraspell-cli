---
to: src/submit/submitEvmTx.ts
skip_if: <%= (!evm).toString() %>
---
<%- h.includeShared('shared/api/submitEvmTx.ejs.t') %>
