---
to: README.md
---
# ParaSpell XCM API — Node.js template

Headless example: build transfers via the [XCM API](https://github.com/paraspell/xcm-tools/tree/main/apps/xcm-api), then sign with **Polkadot API** (substrate) or **viem** (EVM origins).

Generate trimmed variants with Hygen (`xcm-sdk-hygen`) using `--evm`, `--swap`, and `--snowbridge` (no client selection — always PAPI for substrate).

## Environment

<% if (evm) { %>A `.env` file is created at generation time with `PRIVATE_KEY` (empty if you skipped the prompt).

<% } %>| Variable | Used for |
|----------|----------|
| `SUBSTRATE_MNEMONIC` | Substrate routes: sign API-returned call data via PAPI |
<% if (evm) { %>| `PRIVATE_KEY` | EVM routes: `0x`-prefixed hex for viem |
<% } %>

## Usage

```bash
<%= installCmd %>
<%= startCmd %><% if (evm) { %>
CONFIRM_TRANSFER=true <%= startCmd %><% } %>
```

<% if (evm) { %>`<%= startCmd %>` performs a **dry run** by default: it prints the planned
transfer but broadcasts nothing. Set `CONFIRM_TRANSFER=true` to sign and submit
a **real** transaction on the configured (mainnet) network.
<% } else { %>Substrate routes use dev accounts (`//Alice`, `//Bob`) and run the transfer when
you execute `<%= startCmd %>`.
<% } %>

Provide `SUBSTRATE_MNEMONIC` / `PRIVATE_KEY` via a local `.env` file (already
git-ignored) rather than inline on the command line, so secrets don't leak into
your shell history or process list.

## Features

| Feature | Behavior |
|---------|----------|
| Base | `POST /x-transfers` + PAPI `signSubmitAndWatch` |
| Swap | `swapOptions` on API request |
| EVM | Local `@paraspell/sdk` `Builder` + `PRIVATE_KEY` |
| Snowbridge | `Ethereum` / `EthereumTestnet` origins + `@paraspell/evm-snowbridge` |
