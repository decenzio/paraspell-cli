---
to: src/App.tsx
---
import "./App.css";
<% if (swap) { %>
import "@paraspell/swap";
<% } %><% if (evm) { %>
import "@paraspell/evm";
<% } %><% if (snowbridge) { %>
import "@paraspell/evm-snowbridge";
<% } %>
import XcmTransfer from "./XcmTransfer";

const App = () => (
  <>
    <div className="header">
      <h1>Vite + React + </h1>
      <a
        href="https://paraspell.github.io/docs/sdk/getting-started.html"
        target="_blank"
        className="logo"
      >
        <img src="/paraspell.png" alt="ParaSpell logo" />
      </a>
    </div>
    <XcmTransfer />
    <p className="read-the-docs">
      Click on the ParaSpell logo to read the docs
    </p>
    <p className="read-the-docs" style={{ fontSize: "0.85rem", opacity: 0.7 }}>
      Generated with Hygen — client: <%= clientLabel %><% if (evm) { %>, EVM<% } %><% if (swap) { %>, Swap<% } %><% if (snowbridge) { %>, Snowbridge<% } %>
    </p>
  </>
);

export default App;
