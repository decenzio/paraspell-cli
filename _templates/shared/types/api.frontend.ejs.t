<%- h.includeShared('shared/types/common.ejs.t') %>
<%- h.includeShared('shared/types/api.shared.ejs.t') %>

export type FormValues = {
  from: string;
  to: string;
  currency: AssetInfo;
  recipient: string;
  amount: string;<% if (swap) { %>
  swapEnabled?: boolean;
  currencyTo?: AssetInfo;
  exchange?: string;<% } %>
};

<%- h.includeShared('shared/types/wallet.client.ejs.t') %>
