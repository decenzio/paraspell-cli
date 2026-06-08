---
to: README.md
---
# ParaSpell XCM API — Node.js example

Headless example: build transfers via the [XCM API](https://github.com/paraspell/xcm-tools/tree/main/apps/xcm-api), then sign with **Polkadot API** (substrate)<% if (evm) { %> or **viem** (EVM origins)<% } %>.

<% if (evm) { %>## Environment

Add your EVM wallet key to `.env`:

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

Keep `PRIVATE_KEY` in `.env`, not on the command line.
<% } else { %>Substrate routes use dev accounts (`//Alice`, `//Bob`) and run the transfer when
you execute `<%= startCmd %>`.
<% } %>

## Features

| Feature | Behavior |
|---------|----------|
| Base | `POST /x-transfers` + PAPI `signSubmitAndWatch` |<% if (swap) { %>
| Swap | `swapOptions` on API request |<% } %><% if (evm) { %>
| EVM | Local `@paraspell/sdk` `Builder` + `PRIVATE_KEY` |<% } %><% if (snowbridge) { %>
| Snowbridge | `Ethereum` / `EthereumTestnet` origins + `@paraspell/evm-snowbridge` |<% } %>

## License

MIT — see [LICENSE](LICENSE).
