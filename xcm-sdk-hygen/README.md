# XCM SDK & XCM API Hygen generators

Hygen project for ParaSpell **XCM SDK** and **XCM API** starter apps. Template sources live under `_templates/`; generated apps are written only to `generated/` (or your `--out` path).

This package root should contain **`_templates/`**, **`scripts/`**, and **`generated/`** only. If you see `src/` or `public/` here, Hygen was run with the wrong working directory — delete those folders (they are gitignored) and always pass `--out`.

## Layout

```text
xcm-sdk-hygen/
├── _templates/
│   ├── xcm-sdk-react/new/      # XCM SDK — React (Vite + TSX)
│   ├── xcm-sdk-vue/new/        # XCM SDK — Vue
│   ├── xcm-sdk-node/new/       # XCM SDK — Node.js
│   ├── xcm-api-react/new/      # XCM API — React
│   ├── xcm-api-vue/new/        # XCM API — Vue
│   └── xcm-api-node/new/       # XCM API — Node.js
├── scripts/
│   ├── generate-sdk*.mjs       # single SDK app / examples
│   ├── generate-xcm-api*.mjs   # single XCM API app / examples
│   ├── bootstrap-sdk-*-templates.mjs
│   └── bootstrap-xcm-api-*-templates.mjs
└── generated/                  # gitignored output
```

Kitchen-sink sources (edit by hand, then bootstrap):

| Generator | Source |
|-----------|--------|
| XCM SDK React | `templates/react/xcm-sdk` |
| XCM SDK Vue | `templates/vue/xcm-sdk` |
| XCM SDK Node | `templates/node/xcm-sdk` |
| XCM API React | `templates/react/xcm-api` |
| XCM API Vue | `templates/vue/xcm-api` |
| XCM API Node | `templates/node/xcm-api` |

## XCM SDK

### Parameters

| Flag | Values | Default |
|------|--------|---------|
| `--client` | `pjs`, `papi`, `dedot`, `polkadot-js`, `polkadot-api` | `pjs` |
| `--evm` | `true` / `false` | `false` |
| `--swap` | `true` / `false` | `false` |
| `--snowbridge` | `true` / `false` (requires EVM) | `false` |
| `--name` | npm package name | `my-xcm-app` |
| `--out` | output directory | `generated/xcm-sdk/<framework>/<name>` |

### Quick start

```bash
cd xcm-sdk-hygen
npm install

npm run generate:sdk:react -- --name my-app --client pjs --out ./generated/xcm-sdk/react/my-app
npm run generate:sdk:vue -- --name my-app --client papi --evm true
npm run generate:sdk:node -- --name my-app --client pjs --evm true --swap true

npm run generate:sdk -- vue --name my-app --client pjs
```

```bash
npx hygen xcm-sdk-react new
npx hygen xcm-sdk-vue new
npx hygen xcm-sdk-node new
```

### SDK examples

```bash
npm run generate:sdk:examples
npm run generate:sdk:examples:react   # → generated/xcm-sdk/react/*
npm run generate:sdk:examples:vue
npm run generate:sdk:examples:node
```

### Re-sync SDK Hygen from kitchen sink

```bash
npm run bootstrap:sdk
npm run bootstrap:sdk:react
npm run bootstrap:sdk:vue
npm run bootstrap:sdk:node
```

## XCM API

HTTP API + PAPI for substrate; local `@paraspell/sdk` + MetaMask / `PRIVATE_KEY` for EVM origins.

### Parameters

| Flag | Values | Default |
|------|--------|---------|
| `--evm` | `true` / `false` | `false` |
| `--swap` | `true` / `false` | `false` |
| `--snowbridge` | `true` / `false` (requires EVM) | `false` |
| `--name` | npm package name | `my-xcm-api-app` |
| `--out` | output directory | `generated/xcm-api/<framework>/<name>` |

No `--client` flag.

### Quick start

```bash
npm run generate:xcm-api:react -- --name my-app --swap true --out ./generated/xcm-api/react/my-app
npm run generate:xcm-api:vue -- --name my-app --evm true --snowbridge true
npm run generate:xcm-api:node -- --name my-app --evm true

npm run generate:xcm-api -- react --name my-app --swap true
```

```bash
npx hygen xcm-api-react new
npx hygen xcm-api-vue new
npx hygen xcm-api-node new
```

### XCM API examples

```bash
npm run generate:xcm-api:examples   # → generated/xcm-api/{react,vue,node}/*
```

### Re-sync XCM API Hygen from kitchen sink

```bash
npm run bootstrap:xcm-api
npm run bootstrap:xcm-api:react
npm run bootstrap:xcm-api:vue
npm run bootstrap:xcm-api:node
```

## Integrating with paraspell-cli

```javascript
import { runner, Logger } from 'hygen';
import path from 'node:path';

const templates = path.join(__dirname, '../xcm-sdk-hygen/_templates');
const generator = 'xcm-sdk-react'; // or xcm-sdk-vue, xcm-api-react, …

await runner(
  [generator, 'new', `--client=${clientId}`, `--evm=${evm}`, ...],
  { templates, cwd: projectPath, logger: new Logger(console.log.bind(console)) },
);
```

## Template conventions

- **Conditional files** use `skip_if: <%= (condition).toString() %>` in frontmatter.
- **EJS templates** hold parameterized logic (`package.json.ejs.t`, …).
- **Unchanged files** are re-copied via the matching `bootstrap:*` script.
- **Binary assets** (`lightspell.png`, `paraspell.png`) stay as raw files under `_templates/.../public/`; logos are copied with `copyLogo()` after generation (do not bootstrap PNGs as UTF-8).

## Feature matrix (SDK)

| Client | EVM | Swap | Snowbridge |
|--------|-----|------|------------|
| papi / pjs / dedot | optional | optional | optional (EVM only) |

PAPI routes EVM inside `xcm/papi.ts`; PJS and Dedot use `useWalletWithEvm` + `submitEvmIfNeeded`.
