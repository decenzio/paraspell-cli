---
to: README.md
---
# ParaSpell XCM SDK — Node.js example

Headless example using **<%= clientLabel %>** (`<%= sdkPackage %>`) with `signAndSubmit()`.

## Environment

Add your wallet secrets to `.env`:

| Variable | Used for |
|----------|----------|
| `SUBSTRATE_MNEMONIC` | Substrate routes: mnemonic or `//Dev` URI (mnemonics: `"word1 word2 ..."`) |<% if (evm) { %>
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

Default route: `<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'AssetHubPolkadot' %>` → `Hydration` — edit `src/transfer.ts` to customize.

## Docs

- [Send XCM](https://paraspell.github.io/docs/xcm-sdk/send-xcm.html)
- [Getting started](https://paraspell.github.io/docs/sdk/getting-started.html)

## License

MIT — see [LICENSE](LICENSE).
