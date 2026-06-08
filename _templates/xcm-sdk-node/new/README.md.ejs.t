---
to: README.md
---
# ParaSpell XCM SDK — Node.js template

Headless example using **<%= clientLabel %>** (`<%= sdkPackage %>`) with dev accounts (`//Alice`, `//Bob`) and `signAndSubmit()`.

<% if (evm) { %>## Environment

A `.env` file is created automatically when you scaffold this project — add your EVM wallet key there:

| Variable | Used for |
|----------|----------|
| `PRIVATE_KEY` | EVM routes: `0x`-prefixed hex for viem |

<% } %>## Usage

```bash
<%= installCmd %>
<%= startCmd %><% if (evm) { %>
CONFIRM_TRANSFER=true <%= startCmd %><% } %>
```

<% if (evm) { %>EVM routes perform a **dry run** by default: substrate transfers run normally,
but EVM origins require `CONFIRM_TRANSFER=true` to sign and submit a **real**
transaction on the configured (mainnet) network.
<% } else { %>Runs with built-in dev accounts (`//Alice`, `//Bob`) when you execute
`<%= startCmd %>`.
<% } %>

Default route: `<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'AssetHubPolkadot' %>` → `Hydration` — edit `src/index.ts` to customize.

## Docs

- [Send XCM](https://paraspell.github.io/docs/xcm-sdk/send-xcm.html)
- [Getting started](https://paraspell.github.io/docs/sdk/getting-started.html)

## License

MIT — see [LICENSE](LICENSE).
