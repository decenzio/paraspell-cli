---
to: README.md
---
# ParaSpell XCM SDK — Node.js example

Headless example using **<%= clientLabel %>** (`<%= sdkPackage %>`) with `signAndSubmit()`.

## Environment

Add your wallet secrets to `.env`:

| Variable | Used for |
|----------|----------|
| `SUBSTRATE_MNEMONIC` | Substrate routes: mnemonic or `//Dev` URI (quote mnemonics: `"word1 word2 ..."`) |<% if (evm) { %>
| `PRIVATE_KEY` | EVM routes: `0x`-prefixed hex for viem |<% } %>

## Usage

```bash
<%= installCmd %>
<%= startCmd %>
CONFIRM_TRANSFER=true <%= startCmd %>
```

Transfers perform a **dry run** by default. Re-run with `CONFIRM_TRANSFER=true` to sign
and submit a **real** transaction on the configured network.

Keep wallet secrets in `.env`, not on the command line.

Default route: `<%= snowbridge ? 'Ethereum' : evm ? 'Moonbeam' : 'AssetHubPolkadot' %>` → `Hydration` — edit `src/index.ts` to customize.

## Docs

- [Send XCM](https://paraspell.github.io/docs/xcm-sdk/send-xcm.html)
- [Getting started](https://paraspell.github.io/docs/sdk/getting-started.html)

## License

MIT — see [LICENSE](LICENSE).
