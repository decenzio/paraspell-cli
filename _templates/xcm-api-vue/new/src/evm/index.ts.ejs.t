---
to: src/evm/index.ts
skip_if: <%= (!evm).toString() %>
---
<%- h.includeShared('shared/evm/index.ejs.t') %>
