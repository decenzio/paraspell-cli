# XCM SDK Hygen generators

Single Hygen project for ParaSpell **XCM SDK** templates. Each framework has its own template set under `_templates/` and dedicated npm scripts.

## Layout

```text
xcm-sdk-hygen/
├── _templates/
│   ├── xcm-sdk-react/new/    # React (Vite + TSX)
│   ├── xcm-sdk-vue/new/      # Vue (Vite + SFC)
│   └── xcm-sdk-node/new/     # Node.js (headless TS)
├── scripts/
│   ├── generate.mjs              # Unified CLI (--framework react|vue)
│   ├── generate-react.mjs
│   ├── generate-vue.mjs
│   ├── generate-examples.mjs     # React + Vue examples
│   ├── generate-examples-react.mjs
│   ├── generate-examples-vue.mjs
│   ├── bootstrap-react-static-templates.mjs
│   └── bootstrap-vue-static-templates.mjs
└── generated/                    # gitignored
```

Source kitchen-sink templates (edited by hand):

- React: `templates/react/xcm-sdk`
- Vue: `templates/vue/xcm-sdk`
- Node: `templates/node/xcm-sdk`

## Parameters

Same flags for every framework:

| Flag | Values | Default |
|------|--------|---------|
| `--client` | `pjs`, `papi`, `dedot`, `polkadot-js`, `polkadot-api` | `pjs` |
| `--evm` | `true` / `false` | `false` |
| `--swap` | `true` / `false` | `false` |
| `--snowbridge` | `true` / `false` (requires EVM) | `false` |
| `--name` | npm package name | `my-xcm-app` |
| `--out` | output directory | `generated/<framework>/<name>` |

## Quick start

```bash
cd xcm-sdk-hygen
npm install

# React (default)
npm run generate:react -- --name my-app --client pjs --out ./generated/react/my-app

# Vue
npm run generate:vue -- --name my-app --client papi --evm true --out ./generated/vue/my-app

# Node
npm run generate:node -- --name my-app --client pjs --evm true --swap true --out ./generated/node/my-app

# Unified entry (framework as first arg or --framework)
npm run generate -- vue --name my-app --client pjs
npm run generate -- --framework react --name my-app --client pjs
```

Interactive Hygen:

```bash
npx hygen xcm-sdk-react new
npx hygen xcm-sdk-vue new
npx hygen xcm-sdk-node new
```

## Generate all examples

```bash
npm run generate:examples          # React + Vue + Node
npm run generate:examples:react    # generated/examples/react/*
npm run generate:examples:vue      # generated/examples/vue/*
npm run generate:examples:node     # generated/examples/node/*
```

## Re-sync static Hygen files from source templates

After editing `templates/react/xcm-sdk` or `templates/vue/xcm-sdk`:

```bash
npm run bootstrap:react
npm run bootstrap:vue
npm run bootstrap:node
# or all:
npm run bootstrap
```

## Integrating with paraspell-cli

```javascript
import { runner, Logger } from 'hygen';
import path from 'node:path';

const templates = path.join(__dirname, '../xcm-sdk-hygen/_templates');
const generator =
  framework === 'vue'
    ? 'xcm-sdk-vue'
    : framework === 'node'
      ? 'xcm-sdk-node'
      : 'xcm-sdk-react';

await runner(
  [generator, 'new', `--client=${clientId}`, `--evm=${evm}`, ...],
  { templates, cwd: projectPath, logger: new Logger(console.log.bind(console)) },
);
```

## Template conventions

- **Conditional files** use `skip_if: <%= (condition).toString() %>` in frontmatter.
- **EJS templates** hold parameterized logic (`package.json.ejs.t`, `XcmTransfer*.ejs.t`, …).
- **Unchanged files** are re-copied via the matching `bootstrap:*` script.

## Feature matrix

| Client | EVM | Swap | Snowbridge |
|--------|-----|------|------------|
| papi / pjs / dedot | optional | optional | optional (EVM only) |

PAPI routes EVM inside `xcm/papi.ts`; PJS and Dedot use `useWalletWithEvm` + `submitEvmIfNeeded`.
