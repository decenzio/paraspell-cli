---
to: src/xcm/evmTransfer.ts
skip_if: <%= (!evm).toString() %>
---
<%- h.includeShared('shared/xcm/evmTransfer.sdk.ejs.t') %>
