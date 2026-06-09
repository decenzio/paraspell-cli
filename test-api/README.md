# ParaSpell XCM API — Node.js example

Headless example: build transfers via the [XCM API](https://github.com/paraspell/xcm-tools/tree/main/apps/xcm-api), then sign with **Polkadot API** (substrate).

## Environment

Add your wallet secrets to `.env`:

| Variable | Used for |
|----------|----------|
| `SUBSTRATE_MNEMONIC` | Substrate routes: mnemonic or `//Dev` URI (quote mnemonics: `"word1 word2 ..."`) |

## Usage

```bash
pnpm install
pnpm start
CONFIRM_TRANSFER=true pnpm start
```

Transfers perform a **dry run** by default. Re-run with `CONFIRM_TRANSFER=true` to sign
and submit a **real** transaction on the configured network.

Keep wallet secrets in `.env`, not on the command line.

## Features

| Feature | Behavior |
|---------|----------|
| Base | `POST /x-transfers` + PAPI `signSubmitAndWatch` |
| Swap | `swapOptions` on API request |

## License

MIT — see [LICENSE](LICENSE).
