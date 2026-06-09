---
to: README.md
---
# ParaSpell XCM API — Node.js example

Headless example: build transfers via the [XCM API](https://github.com/paraspell/xcm-tools/tree/main/apps/xcm-api), then sign with **Polkadot API** (substrate)<% if (evm) { %> or **viem** (EVM origins)<% } %>.

## Environment

Add your wallet secrets to `.env`:

| Variable | Used for |
|----------|----------|
| `SUBSTRATE_MNEMONIC` | Substrate routes: mnemonic or `//Dev` URI (quote mnemonics: `"word1 word2 ..."`) |<% if (evm) { %>
| `PRIVATE_KEY` | EVM routes: `0x`-prefixed hex for viem |<% } %>
| `PORT` | Optional. HTTP port (default `3000`) |

## Usage

```bash
<%= installCmd %>
<%= startCmd %>
curl -X POST http://localhost:3000/
```

The server starts without submitting a transfer. Send `POST /` to sign and submit the configured XCM transfer.

Keep wallet secrets in `.env`, not on the command line.

## Features

| Feature | Behavior |
|---------|----------|
| Base | `POST /x-transfers` + PAPI `signSubmitAndWatch` |<% if (swap) { %>
| Swap | `swapOptions` on API request |<% } %><% if (evm) { %>
| EVM | Local `@paraspell/sdk` `Builder` + `PRIVATE_KEY` |<% } %><% if (snowbridge) { %>
| Snowbridge | `Ethereum` / `EthereumTestnet` origins + `@paraspell/evm-snowbridge` |<% } %>

## License

MIT — see [LICENSE](LICENSE).
