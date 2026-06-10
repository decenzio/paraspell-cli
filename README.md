<h1 align="center">
create-paraspell ✨ — scaffold XCM starter apps
</h1>

<p align="center">
<img width="400" alt="ParaSpell logo" src="https://github.com/paraspell/xcm-tools/assets/55763425/a65e3626-84cf-444b-ab77-9375508e5895">
</p>

<p align="center">
  Official CLI to bootstrap <strong>XCM SDK</strong> and <strong>XCM API</strong> apps — React, Vue, or Node — in seconds.
</p>

<p align="center">
  <a href="https://paraspell.xyz">Website</a> ·
  <a href="https://paraspell.github.io/docs/">Documentation</a> ·
  <a href="https://github.com/paraspell/xcm-tools">XCM Tools monorepo</a>
</p>

<br>

**What you can generate:**

- **[XCM SDK](https://github.com/paraspell/xcm-tools/tree/main/packages/sdk) 🪄** — Cross-chain dApps with an in-app client library.
  - **Clients:** `papi` ([Polkadot API](https://github.com/paraspell/xcm-tools/tree/main/packages/sdk)), `pjs` ([Polkadot.js](https://github.com/paraspell/xcm-tools/tree/main/packages/sdk-pjs)), `dedot` ([Dedot](https://github.com/paraspell/xcm-tools/tree/main/packages/sdk-dedot))
  - **Extensions (optional):** [EVM](https://github.com/paraspell/xcm-tools/tree/main/packages/evm), [Swap](https://paraspell.github.io/docs/xcm-sdk/getting-started.html#install-swap-extension), [Snowbridge](https://github.com/paraspell/xcm-tools/tree/main/packages/evm-snowbridge)
- **[XCM API](https://github.com/paraspell/xcm-tools/tree/main/apps/xcm-api) ⚡️** — Package-less XCM integration: your app calls the API, signs locally, and stays lean.

**Frameworks** : React (Vite), Vue (Vite), or Node.js (headless scripts).

<br>

## Quick start

Run the CLI in any empty folder (interactive prompts guide you through type, framework, client, and features):

```bash
npm create paraspell@latest
```

Then install and start the dev server:

```bash
cd my-app
pnpm install
pnpm run dev
```

<details><summary><b>Other package managers</b></summary>
<br>

| Tool | Command |
|------|---------|
| **npm** | `npm create paraspell@latest` |
| **yarn** | `yarn create paraspell` |
| **pnpm** | `pnpm create paraspell` |
| **bun** | `bun create paraspell` |
| **npx** | `npx create-paraspell@latest` |

**Global binary** (after `npm install -g create-paraspell`):

```bash
create-paraspell
```

</details>

<details><summary><b>For Agents & CI</b></summary>
<br>

Use `sdk` or `api` as the first argument (or `--type`), plus `--name`. SDK projects also need `--client`.

```bash
npx create-paraspell@latest sdk react --name my-app --client pjs --package-manager pnpm
npx create-paraspell@latest api vue --name my-api --package-manager npm
npx create-paraspell@latest --type sdk --framework node --name my-node --client dedot --evm true
```

```bash
create-paraspell --help
create-paraspell sdk --help
create-paraspell api --help
```

On a TTY, omitting `--name` or `--client` (SDK) opens prompts. Without a TTY, sensible defaults apply.

| Flag | Values | Default |
|------|--------|---------|
| `--type` | `sdk`, `api` | required when not using `sdk`/`api` subcommand |
| `--framework` | `react`, `vue`, `node` | `react` |
| `--client` (SDK only) | `papi`, `pjs`, `dedot` | `pjs` |
| `--evm`, `--swap`, `--snowbridge` | `true` / `false` | `false` (`snowbridge` requires `--evm true`) |
| `--package-manager` | `npm`, `yarn`, `pnpm`, `bun` | `pnpm` |
| `--name`, `--out` | | `./<name>` in the current directory |

</details>

<details><summary><b>Repository development</b></summary>
<br>

Clone this repo and use the same flags via dev scripts. Output defaults to `generated/` unless you pass `--out`:

```bash
npm install
npm run build
npm run execute          # run the built CLI locally
npm run generate         # interactive flow via tsx (source)

npm run generate:sdk -- react --name my-app --client pjs --package-manager pnpm
npm run generate:xcm-api -- vue --name my-api --package-manager npm
```

**Package layout:**

```text
├── index.js                  # starting point
├── dist/                     # built CLI
├── assets/                   # bundled static files
├── _templates/               # Hygen generators
│   ├── shared/               # shared EJS partials (evm, xcm)
│   ├── xcm-sdk-{react,vue,node}/
│   └── xcm-api-{react,vue,node}/
├── shared/                   # Hygen helpers consumed by templates (CommonJS)
│   ├── feature-flags.cjs
│   ├── package-manager.cjs
│   └── versions.cjs
└── src/                      # TypeScript CLI source
    ├── index.ts              # entry → dist/
    ├── run-cli.ts            # argv routing & agent flow
    ├── interactive.ts        # prompts & banner
    └── shared/               # hygen-runner, parsers, prompts, etc.
```

**Publish:**

```bash
npm run build
npm pack
npm publish --access public
```

</details>

<details><summary><b>Testing</b></summary>
<br>

```bash
npm run typecheck          # type-check the CLI
npm test                   # scaffold variants + check structure
npm run test:build         # production build each variant (slow)
npm run test:all           # structure + build
npm run test:watch         # structure tests in watch mode
npm run test:generate      # regenerate generated/ only
SKIP_GENERATE=1 npm test   # skip scaffolding, reuse generated/
```

</details>
