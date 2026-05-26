# ParaSpell XCM SDK — Node.js template

Headless example for sending XCM transfers from Node.js using dev accounts (`//Alice`, `//Bob`) and `signAndSubmit()` — no browser wallet or manual `build()` step.

Same builder API as the [React](../../react/xcm-sdk) and [Vue](../../vue/xcm-sdk) templates. Generate a trimmed variant with Hygen (`xcm-sdk-hygen`) using `--client`, `--evm`, `--swap`, and `--snowbridge`.

## Usage

```bash
pnpm install
pnpm start
```

This example project runs with built-in defaults (no env parsing in `index.ts`).
When generated with Hygen, default `from` is:

- `Ethereum` for Snowbridge builds
- `Moonbeam` for EVM builds
- `AssetHubPolkadot` for non-EVM builds

## Core example

See `src/index.ts`:

```ts
const txHash = await Builder()
  .from("AssetHubPolkadot")
  .to("Hydration")
  .currency({ symbol: "DOT", amount: "0.1" })
  .recipient("//Bob")
  .sender("//Alice")
  .signAndSubmit();

await builder.disconnect();
```

## Feature markers

Search the template for feature markers (same idea as React/Vue):

| Marker | Feature |
|--------|---------|
| `PJS_CLIENT` / `DEDOT_CLIENT` | Polkadot.js or Dedot client |
| `SWAP_FEATURE` | Cross-chain swap (`signAndSubmitAll`) |
| `EVM_FEATURE` | EVM origins via `PRIVATE_KEY` + `@paraspell/evm` |
| `SNOWBRIDGE_FEATURE` | Ethereum ↔ Polkadot via `@paraspell/evm-snowbridge` |

## Docs

- [XCM SDK documentation](https://paraspell.github.io/docs/xcm-sdk/send-xcm.html)
- [Getting started](https://paraspell.github.io/docs/sdk/getting-started.html)

## License

MIT — see [LICENSE](LICENSE).
