---
to: src/types.ts
---
<%- h.includeShared('shared/types/api.frontend.ejs.t') %>
<% if (evmWallet) { %>
<%- h.includeShared('shared/types/wallet.evm.ejs.t') %>
<% } %>
