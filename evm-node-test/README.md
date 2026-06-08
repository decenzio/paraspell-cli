# ParaSpell XCM SDK — Node.js template

Headless example for sending XCM transfers from Node.js using dev accounts (`//Alice`, `//Bob`) and `signAndSubmit()` — no browser wallet or manual `build()` step.

Same builder API as the [React](../../react/xcm-sdk) and [Vue](../../vue/xcm-sdk) templates. Generate a trimmed variant with Hygen (`xcm-sdk-hygen`) using `--client`, `--evm`, `--swap`, and `--snowbridge`.

## Environment

A `.env` file is created at generation time. Set your EVM wallet key there:

| Variable | Used for |
|----------|----------|
| `PRIVATE_KEY` | EVM routes: `0x`-prefixed hex for viem |

## Usage

```bash
pnpm install
pnpm start
```

Default `from` is:

- `Ethereum`

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

## Docs

- [XCM SDK documentation](https://paraspell.github.io/docs/xcm-sdk/send-xcm.html)
- [Getting started](https://paraspell.github.io/docs/sdk/getting-started.html)

## License

MIT — see [LICENSE](LICENSE).
