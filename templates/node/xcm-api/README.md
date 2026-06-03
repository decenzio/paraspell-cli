# ParaSpell XCM API — Node.js template

Headless example: build transfers via the [XCM API](https://github.com/paraspell/xcm-tools/tree/main/apps/xcm-api), then sign with **Polkadot API** (substrate) or **viem** (EVM origins).

Generate trimmed variants with Hygen (`xcm-sdk-hygen`) using `--evm`, `--swap`, and `--snowbridge` (no client selection — always PAPI for substrate).

## Environment

| Variable | Used for |
|----------|----------|
| `SUBSTRATE_MNEMONIC` | Substrate routes: sign API-returned call data via PAPI |
| `PRIVATE_KEY` | EVM routes: `0x`-prefixed hex for viem |

## Usage

```bash
pnpm install
SUBSTRATE_MNEMONIC="your twelve words ..." pnpm start
```

## Features

| Feature | Behavior |
|---------|----------|
| Base | `POST /x-transfers` + PAPI `signSubmitAndWatch` |
| Swap | `swapOptions` on API request |
| EVM | Local `@paraspell/sdk` `Builder` + `PRIVATE_KEY` |
| Snowbridge | `Ethereum` / `EthereumTestnet` origins + `@paraspell/evm-snowbridge` |
